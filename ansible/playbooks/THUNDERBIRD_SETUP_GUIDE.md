# Thunderbird IMAP Setup Guide

## Prerequisites
- Mail user created in database
- DNS records pointing to mail server
- Ports 993 (IMAPS) and 587 (Submission) accessible

## Automatic Setup (Recommended)

1. **Open Thunderbird**
2. Click **"Set up an account"** or go to **Menu → New → Existing Mail Account**
3. Enter your details:
   - **Your name:** John Doe
   - **Email address:** john@phalkons.com
   - **Password:** [your password]
4. Click **Continue**
5. Thunderbird will auto-detect settings. Click **Done**

---

## Manual Setup (If Auto-detect Fails)

### Step 1: Create New Account
1. Open Thunderbird
2. Go to **Menu (☰) → Account Settings**
3. Click **Account Actions → Add Mail Account**

### Step 2: Enter Account Information
```
Your name:        John Doe
Email address:    john@phalkons.com
Password:         [your password]
```

### Step 3: Click "Manual config" or "Configure manually"

### Step 4: Configure Incoming Mail (IMAP)

```
Protocol:         IMAP
Hostname:         cucho1.phalkons.com
Port:             993
Connection security: SSL/TLS
Authentication:   Normal password
Username:         john@phalkons.com
```

### Step 5: Configure Outgoing Mail (SMTP)

```
Hostname:         cucho1.phalkons.com
Port:             587
Connection security: STARTTLS
Authentication:   Normal password
Username:         john@phalkons.com
```

### Step 6: Click "Re-test" then "Done"

---

## Connection Settings Summary

| Setting | Value |
|---------|-------|
| **IMAP Server** | cucho1.phalkons.com |
| **IMAP Port** | 993 |
| **IMAP Security** | SSL/TLS |
| **SMTP Server** | cucho1.phalkons.com |
| **SMTP Port** | 587 |
| **SMTP Security** | STARTTLS |
| **Username** | Full email address |
| **Password** | User password |

---

## Troubleshooting

### "Unable to connect to mail server"

**Check DNS:**
```bash
nslookup cucho1.phalkons.com
# Should return: 144.202.72.168
```

**Check ports are open:**
```bash
telnet cucho1.phalkons.com 993
telnet cucho1.phalkons.com 587
```

**Test IMAP manually:**
```bash
openssl s_client -connect cucho1.phalkons.com:993
# Type: a1 LOGIN john@phalkons.com password
# Should see: a1 OK Logged in
```

### "Certificate not trusted"

This happens if you're using self-signed certificates. Either:
1. Accept the certificate exception (temporary)
2. Use Let's Encrypt certificates (recommended - already configured!)

### "Authentication failed"

**Verify user exists:**
```bash
ssh phalkonadmin@10.100.0.25
sudo docker exec mailserver-postgres psql -U postgres -d mailserver \
  -c "SELECT username, active FROM mailbox WHERE username='john@phalkons.com';"
```

**Test authentication:**
```bash
sudo doveadm auth test john@phalkons.com password
# Should show: auth succeeded
```

**Check Dovecot logs:**
```bash
sudo journalctl -u dovecot -n 50 --no-pager | grep john@phalkons.com
```

### "Cannot send email"

**Test SMTP connection:**
```bash
telnet cucho1.phalkons.com 587
EHLO test
MAIL FROM:<john@phalkons.com>
RCPT TO:<test@example.com>
QUIT
```

**Check Postfix logs:**
```bash
sudo journalctl -u postfix -n 50 --no-pager | grep john@phalkons.com
```

---

## Advanced: Folder Subscriptions

Thunderbird should automatically see these folders:
- **Inbox** (default)
- **Drafts**
- **Sent**
- **Junk**
- **Trash**

If folders don't appear:
1. Right-click the account → **Subscribe**
2. Check all folders you want to see
3. Click **OK**

---

## Mobile Device Setup (iOS/Android)

### iOS Mail App
1. Settings → Mail → Accounts → Add Account
2. Choose **Other** → **Add Mail Account**
3. Enter name, email, password, description
4. Tap **Next**
5. Select **IMAP** (not POP)
6. Enter server settings as above

### Android Gmail App
1. Settings → Add Account → Other
2. Enter email address
3. Choose **Personal (IMAP)**
4. Enter password
5. Configure incoming/outgoing servers as above

---

## Testing Email Flow

### Send Test Email
1. Compose new email in Thunderbird
2. Send to: testuser1@phalkons.com
3. Check if it appears in testuser1's inbox

### Receive Test Email
```bash
# From server:
echo "Test from server" | mail -s "Test" john@phalkons.com

# Should appear in Thunderbird within seconds
```

---

## Performance Tips

### Enable Message Caching
1. Account Settings → Synchronization & Storage
2. Check **"Keep messages for this account on this computer"**
3. Adjust disk space limit

### Compact Folders Regularly
- Right-click folders → **Compact**
- Or enable automatic compacting in settings

---

## Security Recommendations

1. **Use strong passwords** (12+ characters, mixed case, numbers, symbols)
2. **Enable 2FA** (future enhancement)
3. **Review login history** regularly
4. **Use encrypted connections only** (never POP3/SMTP without TLS)
5. **Keep Thunderbird updated**

---

## Quick Reference Card

Print this and keep handy:

```
┌─────────────────────────────────────────┐
│   PHALKONS MAIL - THUNDERBIRD SETUP     │
├─────────────────────────────────────────┤
│ IMAP (Incoming)                         │
│   Server:   cucho1.phalkons.com         │
│   Port:     993                         │
│   Security: SSL/TLS                     │
│                                         │
│ SMTP (Outgoing)                         │
│   Server:   cucho1.phalkons.com         │
│   Port:     587                         │
│   Security: STARTTLS                    │
│                                         │
│ Username: your-email@phalkons.com       │
│ Password: [your password]               │
│                                         │
│ Support: postmaster@phalkons.com        │
└─────────────────────────────────────────┘
```
