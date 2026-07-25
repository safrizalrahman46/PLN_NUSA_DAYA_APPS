<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\ReportRequest;
use App\Services\DigikitService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ReportController extends Controller
{
    protected DigikitService $digikitService;

    public function __construct(DigikitService $digikitService)
    {
        $this->digikitService = $digikitService;
    }

    /**
     * Get list of reports for a region, date, and optional unit.
     */
    public function report(ReportRequest $request)
    {
        try {
            $user = $request->user();
            $kdRegion = $request->kd_region;
            $tanggal = $request->tanggal;
            $kdUnit = $request->kd_unit; // optional

            $data = $this->digikitService->getReportLogsheet($user, $kdRegion, $tanggal, $kdUnit);

            return response()->json([
                'success' => true,
                'message' => 'Reports retrieved successfully',
                'reports' => $data['data'] ?? []
            ]);
        } catch (\Exception $e) {
            Log::error('Report listing error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch reports: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get detail for a specific report based on idBebanUld, kd_region, tanggal, and jam.
     */
    public function detail(Request $request, $idBebanUld)
    {
        try {
            $request->validate([
                'tanggal' => 'required|date_format:Y-m-d',
                'jam' => 'required|string', // e.g. 22:00:00 or 11:00
            ]);

            $user = $request->user();
            $kdRegion = $request->get('kd_region', $user->kd_region ?? '05');
            $tanggal = $request->get('tanggal');
            $jam = $request->get('jam');

            $data = $this->digikitService->getDetailReportLogsheet($user, $idBebanUld, $kdRegion, $tanggal, $jam);

            return response()->json([
                'success' => true,
                'message' => 'Report detail retrieved successfully',
                'data' => $data['data'] ?? null
            ]);
        } catch (\Illuminate\Validation\ValidationException $ve) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $ve->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Report detail error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch report detail: ' . $e->getMessage()
            ], 500);
        }
    }
}
