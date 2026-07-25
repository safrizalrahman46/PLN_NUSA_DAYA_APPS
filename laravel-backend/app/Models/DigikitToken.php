<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DigikitToken extends Model
{
    protected $fillable = [
        'user_id',
        'token',
        'token_type',
        'expires_at',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
