<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;


class WeatherController extends Controller
{
    public function getWeather(Request $request)
    {
        $city = $request->query('city','Dhaka');
        $apiKey = config('services.openweather.key');
        if (!$apiKey) {
            return response()->json([
                'status' => 'error',
                'message' => 'API key not configured'
            ], 500);
        }

        $response = Http::get('https://api.openweathermap.org/data/2.5/weather',[
            'q' => $city,
            'appid' => $apiKey,
            'units' => 'metric'
        ]);

        // dd([
        //     'city' => $city,
        //     'apikey' => "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric",
        // ]);

        if($response->successful()){

            return response()->json([
                'status' => 'success',
                'data' => $response->json()
            ]);

        }else{
            return response()->json([
                'status' => 'error',
                'message' => 'weather not found'
            ], 500);
        }

    }
}
