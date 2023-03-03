


# RDS thresholds 
locals {
  thresholds = {
    BurstBalanceThreshold             = min(max(var.burst_balance_threshold, 0), 100)
    ReplicaLagWarningThreshold        = max(var.replica_lag_warning_threshold, 0)
    ReplicaLagCriticalThreshold       = max(var.replica_lag_critical_threshold, 0)
    CPUUtilizationWarningThreshold    = min(max(var.cpu_utilization_warning_threshold, 0), 100)
    CPUUtilizationCriticalThreshold   = min(max(var.cpu_utilization_critical_threshold, 0), 100)
    DiskQueueDepthWarningThreshold    = max(var.disk_queue_depth_warning_threshold, 0)
    FreeableMemoryWarningThreshold    = max(var.freeable_memory_warning_threshold, 0)
    FreeableMemoryCriticalThreshold   = max(var.freeable_memory_critical_threshold, 0)
    FreeStorageSpaceWarningThreshold  = max(var.free_storage_space_warning_threshold, 0)
    FreeStorageSpaceCriticalThreshold = max(var.free_storage_space_critical_threshold, 0)
    SwapUsageWarningThreshold         = max(var.swap_usage_warning_threshold, 0)
    ReadLatencyWarningThreshold       = max(var.read_latency_warning_threshold, 0)
    WriteLatencyWarningThreshold      = max(var.write_latency_warning_threshold, 0)
  }
}
