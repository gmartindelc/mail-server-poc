# Assistant Rules for Mail Server Cluster PoC Project

## 1. Session Startup Protocol

### 1.1 Initial Session Steps

1. **Always begin** by reading the `planning.md` file to understand:

   - Current project phase and objectives
   - Recent decisions and context
   - Known issues or blockers
   - Upcoming milestones

2. **Immediately check** `tasks.md` before beginning any work:

   - Review priority order (P0 → P1 → P2 → P3)
   - Identify assigned tasks for current session
   - Note any dependencies or prerequisites

3. **Verify context** from previous session:
   - Check last session's notes in `session_logs/`
   - Review any unresolved items from previous work

## 2. Task Management Rules

### 2.1 Before Starting Work

- **Always reference** the PRD (Mail_Server_POC_PRD.md) for requirements
- **Confirm understanding** of task requirements with the user
- **Identify** any missing information needed to complete the task
- **Check** if task requires updates to documentation

### 2.2 During Task Execution

- **Document** all commands run and configurations made
- **Note** any deviations from planned approach with rationale
- **Capture** output snippets, error messages, and resolutions
- **Update** `tasks.md` with progress comments

### 2.3 Task Completion Protocol

- **Mark tasks as completed** in `tasks.md` with:

  - Completion timestamp
  - Brief summary of work done
  - Any follow-up actions needed
  - Reference to documentation updates

- **Verify completion criteria** match PRD requirements
- **Update** relevant documentation files
- **Notify** user of completion and next recommended steps

## 3. Discovery of New Tasks

### 3.1 When New Tasks Are Identified

1. **Immediately add** to `tasks.md` with:

   - Clear, actionable description
   - Priority level (P0-P3)
   - Dependencies on other tasks
   - Estimated effort (if possible)

2. **Categorize** tasks appropriately:

   - **Bug Fixes**: Issues discovered during implementation
   - **Enhancements**: Improvements beyond PRD requirements
   - **Documentation**: Missing or unclear documentation
   - **Technical Debt**: Code/configuration quality issues

3. **Prioritize** based on:
   - Impact on project success criteria
   - Dependencies with other tasks
   - Risk mitigation needs
   - User/stakeholder requests

## 4. Documentation Requirements

### 3.4 Coding Standards

1. **Follow the coding best practices**
2. **Prefer the use of .env files for configuration**
3. **Use meaningful variable names**
4. **Document all changes and decisions in the PRD**
5. **Use consistent formatting and headings**
6. **Use clear and concise language**
7. **Prefer parameterized values than hard-coded values**
8. **Propose folder/file structures**

1

### 4.1 Mandatory Updates

**Always update** these documents when relevant:

1. **`tasks.md`**: Task status, new discoveries, blockers
2. **`planning.md`**: Timeline adjustments, decisions, lessons learned
3. **`session_logs/[date].md`**: Detailed session activities
4. **Component-specific docs**: Config files, setup procedures

### 4.2 Documentation Standards

- **Use clear headings** and consistent formatting
- **Include timestamps** for all updates
- **Reference related tasks** and PRD sections
- **Add troubleshooting sections** for complex procedures

## 5. Communication Protocol

### 5.1 Session Reporting

- **Begin session** with status update based on `planning.md` and `tasks.md`
- **End session** with summary of:
  - Completed work
  - New tasks discovered
  - Current blockers
  - Next session recommendations

### 5.2 Decision Documentation

- **Record** all significant decisions in `planning.md`
- **Note** alternatives considered and rationale for choice
- **Document** any assumptions made
- **Flag** decisions needing stakeholder approval

## 6. Quality Assurance

### 6.1 Validation Checks

**Before marking any task complete:**

- Verify against PRD requirements
- Test functionality (if applicable)
- Check documentation is updated
- Ensure no regression introduced

### 6.2 Security Compliance

- **Always verify** security requirements from PRD Section 4.5
- **Check** VPN-only access for internal services
- **Validate** authentication and authorization setup
- **Confirm** monitoring integration

## 7. File Structure Maintenance

### 7.1 Required Files

Ensure these files exist and are maintained:

```
project_root/
├── Mail_Server_POC_PRD.md          # Master requirements document
├── assistant_rules.md              # This file
├── planning.md                     # Current plan and context
├── tasks.md                        # Task tracking
├── session_logs/                   # Individual session notes
│   └── YYYY-MM-DD.md
├── configs/                        # Configuration files
├── scripts/                        # Automation scripts
└── documentation/                  # Additional documentation
```

### 7.2 Version Control

- **Track changes** to all key files
- **Maintain backups** of critical configurations
- **Use consistent naming** conventions
- **Archive old versions** when major changes made

## 8. Emergency Procedures

### 8.1 When Blocked

1. **Document** the blocker clearly in `tasks.md`
2. **Note** attempted solutions
3. **Escalate** to user with recommended options
4. **Update** `planning.md` with impact assessment

### 8.2 When Requirements Conflict

1. **Reference** the PRD for clarification
2. **Document** the conflict in `planning.md`
3. **Present** options to user with recommendations
4. **Update** documentation based on resolution

---

## Session Logs

### Recent Sessions

#### Session: 2024-12-18 (Terraform Infrastructure Setup)
**Duration:** ~3 hours  
**Status:** ✅ Complete  
**Focus:** Terraform foundation, Vultr integration, secure credential handling

**Key Achievements:**
- ✅ Created Vultr resource management scripts (9 scripts)
- ✅ Fixed Terraform Vultr provider v2.x compatibility issues
- ✅ Implemented secure credential extraction system
- ✅ Generated comprehensive documentation (13 guides, ~85KB)
- ✅ Automated backup schedule configuration
- ✅ CSV auto-cleanup after documentation generation

**Files Created:** 27 files (scripts, configs, documentation)

**Issues Resolved:**
- `enable_private_network` deprecated attribute (main.tf line 35)
- Backup schedule requirement for enabled backups
- Sensitive credential exposure in console output

**Next Session Priority:**
- Deploy first VPS instance
- Test credential extraction
- Begin system hardening (Task 1.1.2)

**Detailed Log:** `session_logs/session_2024-12-18.md`

---

## Quick Reference Checklist

**Start of Session:**

- [ ] Read `planning.md`
- [ ] Check `tasks.md`
- [ ] Review last session log

**During Session:**

- [ ] Reference PRD for requirements
- [ ] Document commands and outputs
- [ ] Add new tasks as discovered
- [ ] Update relevant documentation

**End of Session:**

- [ ] Mark completed tasks
- [ ] Update `planning.md` with progress
- [ ] Create session log
- [ ] Provide summary and next steps

**File Updates Required:**

- [ ] `tasks.md` - Task status
- [ ] `planning.md` - Project status
- [ ] Session log - Detailed activities
- [ ] Component docs - As needed

---

**Version:** 1.0  
**Created:** 2025-12-15  
**Based on PRD:** Mail_Server_POC_PRD.md v1.0  
**Purpose:** Ensure consistent project execution and documentation
