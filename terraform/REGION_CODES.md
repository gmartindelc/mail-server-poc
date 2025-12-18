# Vultr Region Codes

*Last updated: 2025-12-18 13:41:11*

This document contains all available Vultr region codes and locations.

## Summary

- **Total Regions:** 32
- **Continents:** 6

## Quick Reference

| Region Code | City | Country | Continent |
|---|---|---|---|
| `jnb` | Johannesburg | ZA | Africa |
| `tlv` | Tel Aviv | IL | Asia |
| `blr` | Bangalore | IN | Asia |
| `del` | Delhi NCR | IN | Asia |
| `bom` | Mumbai | IN | Asia |
| `itm` | Osaka | JP | Asia |
| `nrt` | Tokyo | JP | Asia |
| `icn` | Seoul | KR | Asia |
| `sgp` | Singapore | SG | Asia |
| `mel` | Melbourne | AU | Australia |
| `syd` | Sydney | AU | Australia |
| `fra` | Frankfurt | DE | Europe |
| `mad` | Madrid | ES | Europe |
| `cdg` | Paris | FR | Europe |
| `lhr` | London | GB | Europe |
| `man` | Manchester | GB | Europe |
| `ams` | Amsterdam | NL | Europe |
| `waw` | Warsaw | PL | Europe |
| `sto` | Stockholm | SE | Europe |
| `yto` | Toronto | CA | North America |
| `mex` | Mexico City | MX | North America |
| `atl` | Atlanta | US | North America |
| `ord` | Chicago | US | North America |
| `dfw` | Dallas | US | North America |
| `hnl` | Honolulu | US | North America |
| `lax` | Los Angeles | US | North America |
| `mia` | Miami | US | North America |
| `ewr` | New Jersey | US | North America |
| `sea` | Seattle | US | North America |
| `sjc` | Silicon Valley | US | North America |
| `sao` | São Paulo | BR | South America |
| `scl` | Santiago | CL | South America |

## Africa

| Code | City | Country | Features |
|---|---|---|---|
| `jnb` | Johannesburg | ZA | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |

## Asia

| Code | City | Country | Features |
|---|---|---|---|
| `tlv` | Tel Aviv | IL | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `blr` | Bangalore | IN | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |
| `del` | Delhi NCR | IN | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `bom` | Mumbai | IN | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `itm` | Osaka | JP | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `nrt` | Tokyo | JP | ddos_protection, block_storage_high_perf, block_storage_storage_opt, load_balancers, kubernetes |
| `icn` | Seoul | KR | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `sgp` | Singapore | SG | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |

## Australia

| Code | City | Country | Features |
|---|---|---|---|
| `mel` | Melbourne | AU | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `syd` | Sydney | AU | ddos_protection, block_storage_high_perf, load_balancers, kubernetes |

## Europe

| Code | City | Country | Features |
|---|---|---|---|
| `fra` | Frankfurt | DE | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `mad` | Madrid | ES | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `cdg` | Paris | FR | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `lhr` | London | GB | ddos_protection, block_storage_high_perf, block_storage_storage_opt, load_balancers, kubernetes |
| `man` | Manchester | GB | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `ams` | Amsterdam | NL | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |
| `waw` | Warsaw | PL | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `sto` | Stockholm | SE | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |

## North America

| Code | City | Country | Features |
|---|---|---|---|
| `yto` | Toronto | CA | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `mex` | Mexico City | MX | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `atl` | Atlanta | US | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |
| `ord` | Chicago | US | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |
| `dfw` | Dallas | US | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `hnl` | Honolulu | US | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `lax` | Los Angeles | US | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |
| `mia` | Miami | US | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `ewr` | New Jersey | US | ddos_protection, block_storage_high_perf, block_storage_storage_opt, load_balancers, kubernetes |
| `sea` | Seattle | US | ddos_protection, block_storage_storage_opt, block_storage_high_perf, load_balancers, kubernetes |
| `sjc` | Silicon Valley | US | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |

## South America

| Code | City | Country | Features |
|---|---|---|---|
| `sao` | São Paulo | BR | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |
| `scl` | Santiago | CL | ddos_protection, block_storage_storage_opt, load_balancers, kubernetes |

## Usage in Terraform

```hcl
resource "vultr_instance" "example" {
  plan    = "vc2-1c-1gb"
  region  = "ewr"  # Choose from the codes above
  os_id   = 387
}
```
