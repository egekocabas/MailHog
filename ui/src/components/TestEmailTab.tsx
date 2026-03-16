import { useEffect, useState } from 'react';
import Alert from '@mui/material/Alert';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import CircularProgress from '@mui/material/CircularProgress';
import Stack from '@mui/material/Stack';
import TextField from '@mui/material/TextField';
import type { DockerDesktopClient } from '@docker/extension-api-client-types/dist/v1';
import { sendTestEmail, fetchSettings, saveSettings, extractMessage } from '../api';

interface TestEmailTabProps {
  ddClient: DockerDesktopClient;
}

export function TestEmailTab({ ddClient }: TestEmailTabProps) {
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [sending, setSending] = useState(false);
  const [result, setResult] = useState<'delivered' | 'unverified' | null>(null);

  const defaults = {
    from: 'sender@example.com',
    to: 'recipient@example.com',
    subject: 'Test Email',
    body: 'This is a test email sent from the MailHog Docker Desktop extension.',
  };

  const svc = ddClient.extension.vm!.service!;

  useEffect(() => {
    fetchSettings(svc)
      .then((s) => {
        if (s.testFrom    && s.testFrom    !== defaults.from)    setFrom(s.testFrom);
        if (s.testTo      && s.testTo      !== defaults.to)      setTo(s.testTo);
        if (s.testSubject && s.testSubject !== defaults.subject) setSubject(s.testSubject);
        if (s.testBody    && s.testBody    !== defaults.body)    setBody(s.testBody);
      })
      .catch(() => {/* non-fatal — fall back to empty fields */});
  }, []);

  const handleSend = async () => {
    setSending(true);
    setResult(null);
    const effective = {
      from:    from.trim()    || defaults.from,
      to:      to.trim()      || defaults.to,
      subject: subject.trim() || defaults.subject,
      body:    body.trim()    || defaults.body,
    };
    try {
      const resp = await sendTestEmail(svc, effective);
      setResult(resp.delivered ? 'delivered' : 'unverified');
      // Persist whatever was actually sent so it's restored next time
      fetchSettings(svc)
        .then((s) => saveSettings(svc, {
          ...s,
          testFrom:    effective.from,
          testTo:      effective.to,
          testSubject: effective.subject,
          testBody:    effective.body,
        }))
        .catch(() => {/* non-fatal */});
    } catch (err) {
      ddClient.desktopUI.toast.error(extractMessage(err));
    } finally {
      setSending(false);
    }
  };


  return (
    <Box sx={{ pt: 3, px: 3 }}>
      {/* Alert row — full width above both columns */}
      {result === 'delivered' && (
        <Alert severity="success" sx={{ mb: 2 }}>Email delivered successfully.</Alert>
      )}
      {result === 'unverified' && (
        <Alert severity="warning" sx={{ mb: 2 }}>Email sent but delivery could not be verified.</Alert>
      )}

      {/* Action buttons row */}
      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <Button
          variant="outlined"
          onClick={() => {
            setFrom(''); setTo(''); setSubject(''); setBody(''); setResult(null);
            fetchSettings(svc)
              .then((s) => saveSettings(svc, {
                ...s,
                testFrom:    defaults.from,
                testTo:      defaults.to,
                testSubject: defaults.subject,
                testBody:    defaults.body,
              }))
              .catch(() => {/* non-fatal */});
          }}
          disabled={sending}
          sx={{ flex: 1 }}
        >
          Clear Inputs
        </Button>
        <Button
          variant="contained"
          onClick={handleSend}
          disabled={sending}
          startIcon={sending ? <CircularProgress size={16} color="inherit" /> : undefined}
          sx={{ flex: 1 }}
        >
          {sending ? 'Sending…' : 'Send Test Email'}
        </Button>
      </Box>

      {/* Two-column layout */}
      <Box sx={{ display: 'flex', gap: 3, alignItems: 'flex-start' }}>
        {/* Left column: From, To, Subject */}
        <Stack spacing={2} sx={{ flex: 1 }}>
          <TextField
            label="From"
            InputLabelProps={{ shrink: true }}
            type="email"
            placeholder={defaults.from}
            value={from}
            onChange={(e) => setFrom(e.target.value)}
            disabled={sending}
            fullWidth
          />
          <TextField
            label="To"
            InputLabelProps={{ shrink: true }}
            type="email"
            placeholder={defaults.to}
            value={to}
            onChange={(e) => setTo(e.target.value)}
            disabled={sending}
            fullWidth
          />
          <TextField
            label="Subject"
            InputLabelProps={{ shrink: true }}
            placeholder={defaults.subject}
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            disabled={sending}
            fullWidth
          />
        </Stack>

        {/* Right column: Body */}
        <Box sx={{ flex: 1 }}>
          <TextField
            label="Body"
            InputLabelProps={{ shrink: true }}
            placeholder={defaults.body}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            disabled={sending}
            multiline
            minRows={8}
            fullWidth
          />
        </Box>
      </Box>
    </Box>
  );
}
