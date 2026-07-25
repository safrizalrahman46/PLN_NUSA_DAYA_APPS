<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\LogsheetController;
use App\Http\Controllers\API\ReportController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public Authentication route
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (requires Sanctum bearer token)
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth profile & logout
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Logsheet Management
    Route::get('/units', [LogsheetController::class, 'units']);
    Route::get('/logsheet/format', [LogsheetController::class, 'format']);
    Route::post('/logsheet/submit', [LogsheetController::class, 'submit']);

    // Reports Management
    Route::post('/logsheet/report', [ReportController::class, 'report']);
    Route::post('/logsheet/detail/{idBebanUld}', [ReportController::class, 'detail']);
});
