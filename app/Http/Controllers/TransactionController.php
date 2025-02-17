<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class TransactionController
{
    public function index(): string
    {
        return "Transaction Page";
    }

    public function show(string $id)
    {
        return "Show transacionn ID: {$id}";
    }
}
