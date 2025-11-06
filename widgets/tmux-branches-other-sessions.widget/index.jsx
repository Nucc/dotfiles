import { css } from "uebersicht";

// Read from temp file that's updated by tmux hooks
export const command = `cat /tmp/tmux-branches-$USER.txt 2>/dev/null || echo ""`;

export const refreshFrequency = 500; // Update every 0.5 seconds (fast since we're just reading a file)

export const className = css`
  top: 20%;
  left: 30px;
  transform-origin: right center;
  font-family: "SF Mono", "Menlo", monospace;
  font-size: 13px;
  display: flex;
  gap: 0;
  padding: 0;
  margin: 0;
  .bookmark-container {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 0;
    margin: 0;
    align-items: flex-start;
  }

  .bookmark {
    position: relative;
    background: linear-gradient(135deg, #F44336 0%, #D32F2F 100%);
    color: white;
    padding: 10px 96px 10px 30px;
    font-weight: 500;
    box-shadow:
      0 6px 12px rgba(0, 0, 0, 0.4),
      0 10px 24px rgba(0, 0, 0, 0.3),
      0 14px 36px rgba(0, 0, 0, 0.25),
      0 0 25px rgba(244, 67, 54, 0.5),
      inset 0 -2px 4px rgba(0, 0, 0, 0.2);
    clip-path: polygon(12px 0, 100% 0, 100% 100%, 0 100%);
    animation: pulse 2s ease-in-out infinite;

    width: 220px;
    display: flex;
    align-items: flex-end;
    justify-content: flex-end;
    text-align: right;

  }

  @keyframes pulse {
    0%, 100% {
      box-shadow:
        0 6px 12px rgba(0, 0, 0, 0.4),
        0 10px 24px rgba(0, 0, 0, 0.3),
        0 14px 36px rgba(0, 0, 0, 0.25),
        0 0 25px rgba(244, 67, 54, 0.5),
        inset 0 -2px 4px rgba(0, 0, 0, 0.2);
    }
    50% {
      box-shadow:
        0 6px 12px rgba(0, 0, 0, 0.4),
        0 10px 24px rgba(0, 0, 0, 0.3),
        0 14px 36px rgba(0, 0, 0, 0.25),
        0 0 35px rgba(244, 67, 54, 0.7),
        inset 0 -2px 4px rgba(0, 0, 0, 0.2);
    }
  }

  .bookmark-text {
    font-weight: 600;
    font-size: 12px;
    letter-spacing: 0.3px;
    word-wrap: break-word;
    white-space: normal;
    line-height: 1.4;
    text-align: right;
  }

  .session-label {
    font-size: 11px;
    opacity: 0.85;
    margin-bottom: 2px;
    font-weight: 500;
  }
`;

export const render = ({ output }) => {
  if (!output || output.trim() === "") {
    return null; // Don't show anything if no data
  }

  const lines = output.trim().split("\n").filter(line => line);

  // First line is ACTIVE_SESSION|session_name
  let activeSession = "";
  let windowLines = lines;

  if (lines[0] && lines[0].startsWith("ACTIVE_SESSION|")) {
    activeSession = lines[0].split("|")[1];
    windowLines = lines.slice(1);
  }

  // Parse all windows and filter for:
  // 1. Not in the active session
  // 2. Status is 'needs_interaction' (user-interaction in the requirement)
  const otherSessionWindows = windowLines
    .map(line => {
      const [index, session, name, info, active, claudeState] = line.split("|");
      // Replace underscores with spaces in branch/worktree names
      const formattedInfo = info.replace(/[_-]/g, " ");
      return {
        index,
        session,
        name,
        info: formattedInfo,
        active: active === "1",
        isActiveSession: session === activeSession,
        claudeState: claudeState || "inactive"
      };
    })
    .filter(window =>
      window.session !== activeSession &&
      window.claudeState === 'needs_interaction'
    );

  if (otherSessionWindows.length === 0) {
    return null; // Don't show anything if no windows need interaction
  }

  return (
    <div className="bookmark-container">
      {otherSessionWindows.map((window, i) => (
        <div key={i} className="bookmark">
          <span className="bookmark-text">
            <div className="session-label">{window.session}</div>
            {window.index}: {window.info}
          </span>
        </div>
      ))}
    </div>
  );
};
