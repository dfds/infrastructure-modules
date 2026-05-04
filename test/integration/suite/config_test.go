package main

import (
    "log"
    "os"
)

type envConfig struct {
    DNSZone string
}

var cfg envConfig

func initConfig() {
    cfg = envConfig{
        DNSZone: getEnvStr("INTEGRATION_DNS_ZONE", "qa.qa.dfds.cloud"),
    }
    log.Printf("Test config: DNSZone=%s", cfg.DNSZone)
}

func getEnvStr(key string, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}
