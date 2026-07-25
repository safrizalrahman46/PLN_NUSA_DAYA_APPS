<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use App\Services\DigikitService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    protected DigikitService $digikitService;

    public function __construct(DigikitService $digikitService)
    {
        $this->digikitService = $digikitService;
    }

    /**
     * Handle Flutter user login.
     * Authenticates with DIGIKIT, maps/saves the user locally, and issues a Laravel Sanctum token.
     */
    public function login(LoginRequest $request)
    {
        try {
            $username = $request->username;
            $password = $request->password;

            // 1. Authenticate with DIGIKIT first
            $digikitData = $this->digikitService->login($username, $password);

            $digikitUser = $digikitData['user'];
            
            // 2. Synchronize local User
            $user = User::updateOrCreate(
                ['username' => $digikitUser['username']],
                [
                    'name' => $digikitUser['name'],
                    'email' => $digikitUser['email'] ?? $digikitUser['username'] . '@example.com',
                    'password' => Hash::make($password), // backup local hashing
                    'kd_region' => $digikitUser['kd_region'] ?? '05', // Default region
                    'digikit_password' => $password, // Automatically encrypted by User model cast
                ]
            );

            // 3. Store the DIGIKIT token
            $user->digikitTokens()->updateOrCreate(
                ['user_id' => $user->id],
                [
                    'token' => $digikitData['token'],
                    'token_type' => $digikitData['token_type'] ?? 'Bearer',
                    'expires_at' => now()->addDays(30),
                ]
            );

            // 4. Generate Laravel Sanctum Token for Flutter
            $sanctumToken = $user->createToken('pltd-flutter-token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'token' => $sanctumToken,
                'token_type' => 'Bearer',
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'username' => $user->username,
                    'email' => $user->email,
                    'kd_region' => $user->kd_region,
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('Login error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 401);
        }
    }

    /**
     * Get authenticated user profile.
     */
    public function me(Request $request)
    {
        $user = $request->user();
        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'email' => $user->email,
                'kd_region' => $user->kd_region,
            ]
        ]);
    }

    /**
     * Handle user logout.
     */
    public function logout(Request $request)
    {
        try {
            $user = $request->user();
            
            // Revoke current Sanctum token
            $user->currentAccessToken()->delete();
            
            // Clean up active DIGIKIT tokens
            $user->digikitTokens()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logout failed: ' . $e->getMessage()
            ], 500);
        }
    }
}
