<?php

namespace App\Services;

use App\Models\User;
use App\Models\DigikitToken;
use App\Models\DigikitLog;
use App\Models\DigikitCache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Crypt;
use Carbon\Carbon;

class DigikitService
{
    protected string $baseUrl;

    public function __construct()
    {
        $this->baseUrl = rtrim(config('services.digikit.base_url', 'http://wacb.nusadaya.net/api/'), '/') . '/';
    }

    /**
     * Authenticate with DIGIKIT using credentials.
     *
     * @param string $username
     * @param string $password
     * @param User|null $localUser
     * @return array
     * @throws \Exception
     */
    public function login(string $username, string $password, ?User $localUser = null): array
    {
        $startTime = microtime(true);
        $endpoint = 'login';
        
        try {
            $response = Http::get($this->baseUrl . $endpoint, [
                'username' => $username,
                'password' => $password,
            ]);

            $duration = (int)((microtime(true) - $startTime) * 1000);
            
            $this->logRequest(
                $localUser?->id,
                $endpoint,
                'GET',
                ['username' => $username],
                $response->json(),
                $response->status(),
                $response->successful() ? null : $response->body(),
                $duration
            );

            if ($response->failed()) {
                throw new \Exception('Failed to login to DIGIKIT: ' . ($response->json('message') ?? $response->body()));
            }

            $data = $response->json();
            
            // If we have a local user, save the token
            if ($localUser) {
                DigikitToken::updateOrCreate(
                    ['user_id' => $localUser->id],
                    [
                        'token' => $data['token'],
                        'token_type' => $data['token_type'] ?? 'Bearer',
                        'expires_at' => now()->addDays(30), // standard expiration fallback
                    ]
                );
            }

            return $data;
        } catch (\Exception $e) {
            $duration = (int)((microtime(true) - $startTime) * 1000);
            $this->logRequest(
                $localUser?->id,
                $endpoint,
                'GET',
                ['username' => $username],
                null,
                500,
                $e->getMessage(),
                $duration
            );
            throw $e;
        }
    }

    /**
     * Get or refresh active token for a user.
     *
     * @param User $user
     * @return string
     * @throws \Exception
     */
    public function getOrRefreshTokenForUser(User $user): string
    {
        $activeToken = $user->activeDigikitToken;

        // If token exists and is not close to expiration, return it
        if ($activeToken && ($activeToken->expires_at === null || $activeToken->expires_at->isAfter(now()->addMinutes(5)))) {
            return $activeToken->token;
        }

        // Otherwise, attempt to re-login using stored encrypted password
        if (!$user->digikit_password) {
            throw new \Exception('DIGIKIT credentials not available. Please login again.');
        }

        Log::info("Refreshing DIGIKIT token for user: {$user->username}");
        
        $loginData = $this->login($user->username, $user->digikit_password, $user);
        return $loginData['token'];
    }

    /**
     * Execute a request to DIGIKIT with auto-refresh on 401.
     *
     * @param User $user
     * @param string $method
     * @param string $endpoint
     * @param array $params
     * @param bool $isPostJson
     * @return array
     * @throws \Exception
     */
    protected function executeRequest(User $user, string $method, string $endpoint, array $params = [], bool $isPostJson = false): array
    {
        $token = $this->getOrRefreshTokenForUser($user);
        
        $startTime = microtime(true);
        try {
            $response = $this->sendHttpCall($method, $endpoint, $params, $token, $isPostJson);
            
            // If unauthorized, refresh token and try again once
            if ($response->status() === 401) {
                Log::warning("DIGIKIT returned 401. Retrying after token refresh for user: {$user->username}");
                
                // Force refresh token
                $activeToken = $user->activeDigikitToken;
                if ($activeToken) {
                    $activeToken->delete(); // delete old token
                }
                
                $newToken = $this->getOrRefreshTokenForUser($user);
                $startTime = microtime(true); // reset timer for retried call
                $response = $this->sendHttpCall($method, $endpoint, $params, $newToken, $isPostJson);
            }

            $duration = (int)((microtime(true) - $startTime) * 1000);
            
            $this->logRequest(
                $user->id,
                $endpoint,
                $method,
                $params,
                $response->json(),
                $response->status(),
                $response->successful() ? null : $response->body(),
                $duration
            );

            if ($response->failed()) {
                throw new \Exception('DIGIKIT error: ' . ($response->json('message') ?? $response->body()));
            }

            return $response->json();
        } catch (\Exception $e) {
            $duration = (int)((microtime(true) - $startTime) * 1000);
            $this->logRequest(
                $user->id,
                $endpoint,
                $method,
                $params,
                null,
                500,
                $e->getMessage(),
                $duration
            );
            throw $e;
        }
    }

    /**
     * Send HTTP call to DIGIKIT.
     */
    private function sendHttpCall(string $method, string $endpoint, array $params, string $token, bool $isPostJson): \Illuminate\Http\Client\Response
    {
        $url = $this->baseUrl . $endpoint;
        $client = Http::withToken($token);

        if (strtoupper($method) === 'GET') {
            return $client->get($url, $params);
        }

        if ($isPostJson) {
            return $client->post($url, $params);
        } else {
            return $client->asForm()->post($url, $params);
        }
    }

    /**
     * Get unit formats from DIGIKIT (with caching).
     *
     * @param User $user
     * @param string $kdRegion
     * @param string|null $kdArea
     * @param string|null $kdUnit
     * @return array
     */
    public function getFormatLogsheet(User $user, string $kdRegion, ?string $kdArea = null, ?string $kdUnit = null): array
    {
        // Build unique cache key
        $cacheKey = "format_logsheet_{$kdRegion}_" . ($kdArea ?? 'null') . "_" . ($kdUnit ?? 'null');
        
        // Try reading from custom DB cache
        $cached = DigikitCache::where('key', $cacheKey)->active()->first();
        if ($cached) {
            return json_decode($cached->value, true);
        }

        // Fetch from DIGIKIT
        $endpoint = 'v1/format-logsheet-pltd';
        $params = array_filter([
            'kd_region' => $kdRegion,
            'kd_area' => $kdArea,
            'kd_unit' => $kdUnit,
        ]);

        $data = $this->executeRequest($user, 'GET', $endpoint, $params);

        // Store in custom cache
        // If kd_unit is set, cache for 1 hour, otherwise cache unit list / area list for 2 hours
        $expiryMinutes = $kdUnit ? 60 : 120;
        
        DigikitCache::updateOrCreate(
            ['key' => $cacheKey],
            [
                'value' => json_encode($data),
                'expires_at' => now()->addMinutes($expiryMinutes),
            ]
        );

        return $data;
    }

    /**
     * Submit Logsheet report.
     *
     * @param User $user
     * @param string $kdRegion
     * @param string $messageText
     * @return array
     */
    public function submitLogsheet(User $user, string $kdRegion, string $messageText): array
    {
        $endpoint = 'v1/logsheet-pltd';
        return $this->executeRequest($user, 'POST', $endpoint, [
            'kd_region' => $kdRegion,
            'message_text' => $messageText,
        ], false); // Send as Form params
    }

    /**
     * Get Report List.
     *
     * @param User $user
     * @param string $kdRegion
     * @param string $tanggal
     * @param string|null $kdUnit
     * @return array
     */
    public function getReportLogsheet(User $user, string $kdRegion, string $tanggal, ?string $kdUnit = null): array
    {
        $endpoint = 'logsheet';
        $params = array_filter([
            'kd_region' => $kdRegion,
            'tanggal' => $tanggal,
            'kd_unit' => $kdUnit,
        ]);

        return $this->executeRequest($user, 'POST', $endpoint, $params, false); // Send as Form params
    }

    /**
     * Get Report Detail.
     *
     * @param User $user
     * @param string $idBebanUld
     * @param string $kdRegion
     * @param string $tanggal
     * @param string $jam
     * @return array
     */
    public function getDetailReportLogsheet(User $user, string $idBebanUld, string $kdRegion, string $tanggal, string $jam): array
    {
        $endpoint = 'getLogsheet/' . $idBebanUld;
        $params = [
            'kd_region' => $kdRegion,
            'tanggal' => $tanggal,
            'jam' => $jam,
            'idBebanUld' => $idBebanUld
        ];

        return $this->executeRequest($user, 'POST', $endpoint, $params, false);
    }

    /**
     * Log DIGIKIT Requests and Responses.
     */
    private function logRequest(?int $userId, string $endpoint, string $method, ?array $request, ?array $response, int $statusCode, ?string $error, int $durationMs): void
    {
        try {
            DigikitLog::create([
                'user_id' => $userId,
                'endpoint' => $endpoint,
                'method' => $method,
                'request_payload' => $request,
                'response_payload' => $response,
                'status_code' => $statusCode,
                'error_message' => $error,
                'duration_ms' => $durationMs,
            ]);
        } catch (\Exception $e) {
            Log::error("Failed to write DIGIKIT log: " . $e->getMessage());
        }
    }
}
