# Quick Reference - Update Vultr Docs

## TL;DR

```bash
# Standard workflow - CSV files will be DELETED after processing
python3 update_vultr_docs.py

# Keep CSV files
python3 update_vultr_docs.py --keep-csv
```

## What Happens?

1. ✅ Reads CSV files from `./scripts/`
2. ✅ Generates/updates markdown files in current directory:
   - `PLAN_IDS.md`
   - `REGION_CODES.md`
   - `OS_IDS.md`
3. 🗑️ **DELETES CSV files** (unless `--keep-csv` is used)

## Common Commands

| Command | Description |
|---------|-------------|
| `python3 update_vultr_docs.py` | Update docs, delete CSVs |
| `python3 update_vultr_docs.py --keep-csv` | Update docs, keep CSVs |
| `python3 update_vultr_docs.py --scripts-dir ./data` | Custom CSV location |
| `python3 update_vultr_docs.py --docs-dir ./docs` | Custom output location |
| `./update_vultr_docs.sh` | Bash version (same behavior) |
| `./update_vultr_docs.sh --keep-csv` | Bash version, keep CSVs |

## Complete Workflow

### Option 1: Generate & Update in One Go
```bash
#!/bin/bash
# fetch_and_update.sh

cd scripts
python3 vultr_resource_retriever.py
cd ..
python3 update_vultr_docs.py  # CSVs auto-deleted
```

### Option 2: Keep CSVs for Backup
```bash
#!/bin/bash
# fetch_and_update_with_backup.sh

cd scripts
python3 vultr_resource_retriever.py
cd ..
python3 update_vultr_docs.py --keep-csv
```

### Option 3: Archive CSVs Before Updating
```bash
#!/bin/bash
# fetch_and_archive.sh

cd scripts

# Fetch new data
python3 vultr_resource_retriever.py

# Archive old CSVs
mkdir -p archive
mv vultr_*.csv archive/ 2>/dev/null || true

# Fetch again (since we moved them)
python3 vultr_resource_retriever.py

# Update docs (will delete the new CSVs)
cd ..
python3 update_vultr_docs.py
```

## Why Delete CSV Files?

- **Clean workflow**: Markdown is the source of truth for docs
- **Avoid confusion**: Prevents outdated CSV files
- **Space saving**: CSV files can be regenerated anytime
- **Best practice**: Intermediate files shouldn't clutter the repo

## When to Keep CSV Files?

Use `--keep-csv` when:
- Debugging the conversion process
- Comparing multiple data snapshots
- Need raw data for other tools
- Building custom reports

## Troubleshooting

**Q: My CSV files disappeared!**  
A: By design. Use `--keep-csv` if you need them.

**Q: Can I get the CSVs back?**  
A: Yes, just run `python3 vultr_resource_retriever.py` again.

**Q: Where are the generated markdown files?**  
A: In the directory specified by `--docs-dir` (default: current directory)

## Directory Structure

### Before Running
```
project/
├── scripts/
│   ├── vultr_plans_20251218_131843.csv      ← Will be deleted
│   ├── vultr_regions_20251218_131843.csv    ← Will be deleted
│   └── vultr_os_20251218_131843.csv         ← Will be deleted
└── update_vultr_docs.py
```

### After Running (default)
```
project/
├── scripts/                                  ← CSVs gone
├── PLAN_IDS.md                              ← Generated
├── REGION_CODES.md                          ← Generated
└── OS_IDS.md                                ← Generated
```

### After Running (with --keep-csv)
```
project/
├── scripts/
│   ├── vultr_plans_20251218_131843.csv      ← Kept
│   ├── vultr_regions_20251218_131843.csv    ← Kept
│   └── vultr_os_20251218_131843.csv         ← Kept
├── PLAN_IDS.md                              ← Generated
├── REGION_CODES.md                          ← Generated
└── OS_IDS.md                                ← Generated
```

## Integration Examples

### Makefile
```makefile
.PHONY: update-vultr-data update-vultr-docs

update-vultr-data:
	cd scripts && python3 vultr_resource_retriever.py

update-vultr-docs: update-vultr-data
	python3 update_vultr_docs.py
	@echo "✅ Vultr docs updated (CSVs deleted)"

update-vultr-docs-keep-csv: update-vultr-data
	python3 update_vultr_docs.py --keep-csv
	@echo "✅ Vultr docs updated (CSVs kept)"
```

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Only update if Vultr-related files are being committed
if git diff --cached --name-only | grep -qE "main.tf|variables.tf"; then
    echo "🔄 Updating Vultr documentation..."
    cd scripts && python3 vultr_resource_retriever.py
    cd ..
    python3 update_vultr_docs.py  # Auto-deletes CSVs
    git add PLAN_IDS.md REGION_CODES.md OS_IDS.md
fi
```

### GitHub Actions
```yaml
- name: Update Vultr Documentation
  run: |
    cd scripts
    python3 vultr_resource_retriever.py
    cd ..
    python3 update_vultr_docs.py
    # CSVs are auto-deleted, only markdown files remain
```

## Need More Help?

See the full documentation: `UPDATE_DOCS_README.md`
