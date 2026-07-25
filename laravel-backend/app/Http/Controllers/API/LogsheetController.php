<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\SubmitLogsheetRequest;
use App\Services\DigikitService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class LogsheetController extends Controller
{
    protected DigikitService $digikitService;

    public function __construct(DigikitService $digikitService)
    {
        $this->digikitService = $digikitService;
    }

    /**
     * Get list of units/areas under region.
     * Maps to DIGIKIT endpoint without kd_unit parameter.
     */
    public function units(Request $request)
    {
        try {
            $user = $request->user();
            $kdRegion = $request->get('kd_region', $user->kd_region ?? '05');
            $kdArea = $request->get('kd_area'); // optional filter

            $data = $this->digikitService->getFormatLogsheet($user, $kdRegion, $kdArea, null);

            return response()->json([
                'success' => true,
                'message' => 'Units retrieved successfully',
                'filters' => $data['filters'] ?? null,
                'units' => $data['units'] ?? []
            ]);
        } catch (\Exception $e) {
            Log::error('Units fetching error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch units: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get the logsheet format layout for a specific unit.
     */
    public function format(Request $request)
    {
        try {
            $request->validate([
                'kd_area' => 'required|string',
                'kd_unit' => 'required|string',
            ]);

            $user = $request->user();
            $kdRegion = $request->get('kd_region', $user->kd_region ?? '05');
            $kdArea = $request->get('kd_area');
            $kdUnit = $request->get('kd_unit');

            $data = $this->digikitService->getFormatLogsheet($user, $kdRegion, $kdArea, $kdUnit);

            return response()->json([
                'success' => true,
                'message' => 'Logsheet format retrieved successfully',
                'unit' => $data['unit'] ?? null,
                'format' => $data['format'] ?? null
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $ve->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Format fetching error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch format: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Submit a filled logsheet message text report.
     */
    public function submit(SubmitLogsheetRequest $request)
    {
        try {
            $user = $request->user();
            $kdRegion = $request->kd_region;
            $messageText = $request->message_text;

            $data = $this->digikitService->submitLogsheet($user, $kdRegion, $messageText);

            return response()->json([
                'success' => true,
                'message' => 'Logsheet submitted successfully',
                'data' => $data['data'] ?? null
            ]);
        } catch (\Exception $e) {
            Log::error('Logsheet submit error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to submit logsheet: ' . $e->getMessage()
            ], 500);
        }
    }
}
