package main

import (
    "log"
    "os"
    "strconv"
)

type envConfig struct {
    DNSZone        string
    AtlantisDeploy bool
}

var cfg envConfig

func initConfig() {
    cfg = envConfig{
        DNSZone:        getEnvStr("INTEGRATION_DNS_ZONE", "qa.qa.dfds.cloud"),
        AtlantisDeploy: getEnvBool("INTEGRATION_ATLANTIS_DEPLOY", true),
    }
    log.Printf("Test config: DNSZone=%s AtlantisDeploy=%t", cfg.DNSZone, cfg.AtlantisDeploy)
}

func getEnvStr(key string, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}

func getEnvBool(key string, fallback bool) bool {
    v := os.Getenv(key)
    if v == "" {
        return fallback
    }
    b, err := strconv.ParseBool(v)
    if err != nil {
        log.Printf("Invalid bool for %s=%q, using fallback %t", key, v, fallback)
        return fallback
    }
    return b
}
