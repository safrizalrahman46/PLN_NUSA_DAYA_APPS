<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ReportRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'kd_region' => 'required|string',
            'tanggal' => 'required|date_format:Y-m-d',
            'kd_unit' => 'nullable|string',
        ];
    }
}
