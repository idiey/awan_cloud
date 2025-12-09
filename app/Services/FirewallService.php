<?php

namespace App\Services;

use Illuminate\Support\Facades\Process;
use Exception;

class FirewallService
{
    /**
     * Get UFW status
     */
    public function getUfwStatus(): array
    {
        try {
            $result = Process::run('sudo ufw status verbose');
            $output = $result->output();
            
            if (strpos($output, 'Status: active') !== false) {
                return [
                    'enabled' => true,
                    'output' => $output
                ];
            }
            
            return [
                'enabled' => false,
                'output' => $output
            ];
        } catch (Exception $e) {
            return [
                'enabled' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Enable UFW
     */
    public function enableUfw(): array
    {
        try {
            // Enable UFW with --force to skip prompts
            $result = Process::run('sudo ufw --force enable');
            
            return [
                'success' => true,
                'message' => 'Firewall enabled successfully',
                'output' => $result->output()
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Disable UFW
     */
    public function disableUfw(): array
    {
        try {
            $result = Process::run('sudo ufw disable');
            
            return [
                'success' => true,
                'message' => 'Firewall disabled successfully',
                'output' => $result->output()
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Add firewall rule
     */
    public function addRule($action, $port = null, $protocol = null, $fromIp = null, $direction = 'in'): array
    {
        try {
            $command = "sudo ufw {$action}";
            
            if ($direction && $direction !== 'both') {
                $command .= " {$direction}";
            }
            
            if ($port) {
                $command .= " {$port}";
            }
            
            if ($protocol) {
                $command .= "/{$protocol}";
            }
            
            if ($fromIp) {
                $command .= " from {$fromIp}";
            }
            
            $result = Process::run($command);
            
            // Reload UFW to apply changes
            Process::run('sudo ufw reload');
            
            return [
                'success' => true,
                'message' => 'Rule added successfully',
                'output' => $result->output()
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Delete firewall rule
     */
    public function deleteRule($ruleNumber): array
    {
        try {
            $result = Process::run("sudo ufw --force delete {$ruleNumber}");
            
            return [
                'success' => true,
                'message' => 'Rule deleted successfully',
                'output' => $result->output()
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Reset UFW (delete all rules)
     */
    public function resetUfw(): array
    {
        try {
            $result = Process::run('sudo ufw --force reset');
            
            return [
                'success' => true,
                'message' => 'Firewall reset successfully',
                'output' => $result->output()
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }
}
