package main

import (
    "log"
    "os"
    "strconv"
)

type envConfig struct {
    NodeCount int
    DNSZone   string
}

var cfg envConfig

func initConfig() {
    cfg = envConfig{
        NodeCount: getEnvInt("INTEGRATION_NODE_COUNT", 4),
        DNSZone:   getEnvStr("INTEGRATION_DNS_ZONE", "qa.qa.dfds.cloud"),
    }
    log.Printf("Test config: NodeCount=%d, DNSZone=%s", cfg.NodeCount, cfg.DNSZone)
}

func getEnvInt(key string, fallback int) int {
    if v := os.Getenv(key); v != "" {
        i, err := strconv.Atoi(v)
        if err != nil {
            log.Fatalf("invalid value for %s: %s", key, v)
        }
        return i
    }
    return fallback
}

func getEnvStr(key string, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}
