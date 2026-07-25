<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DigikitCache extends Model
{
    protected $table = 'digikit_caches';
    protected $primaryKey = 'key';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'key',
        'value',
        'expires_at',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];

    /**
     * Scope a query to only include active cache keys.
     */
    public function scopeActive($query)
    {
        return $query->where('expires_at', '>', now());
    }
}
