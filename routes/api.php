<?php

use App\Http\Controllers\Api\WeatherController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/check-key', function () {
    return response()->json([
        'OPENWEATHER_API_KEY' => config('services.openweather.key')
    ]);
});


Route::get('/weather',[WeatherController::class,'getweather']);

