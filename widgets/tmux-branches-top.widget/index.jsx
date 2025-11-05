import { css } from "uebersicht";

// Read from temp file that's updated by tmux hooks
export const command = `cat /tmp/tmux-branches-$USER.txt 2>/dev/null || echo ""`;

export const refreshFrequency = 500; // Update every 1 second (fast since we're just reading a file)

export const className = css`
  top: 160px;
  right: 300px;
  transform-origin: top left;
  font-family: "SF Mono", "Menlo", monospace;
  font-size: 13px;
  display: flex;
  gap: 0;
  padding: 0;
  margin: 0;

  .bookmark-container {
    display: flex;
    flex-direction: row;
    gap: 0px;
    padding: 0;
    margin: 0;
    align-items: flex-end;
  }

  .bookmark {
    position: relative;
    background: linear-gradient(135deg, #4A90E2 0%, #357ABD 100%);
    color: white;
    padding: 12px 24px;
    font-weight: 500;
    box-shadow:
      0 4px 8px rgba(0, 0, 0, 0.3),
      0 8px 16px rgba(0, 0, 0, 0.2),
      0 12px 24px rgba(0, 0, 0, 0.15);
    clip-path: polygon(0 0, calc(100% - 65px) 0, 100% 100%, 16px 100%);
    transform: rotate(-45deg);
    transform-origin: bottom left;

    /* For 45deg rotation, horizontal spacing = width/sqrt(2) - width */
    /* 220px / 1.414 ≈ 155px, so margin should be -(220 - 155) = -65px */
    /* Plus desired gap between bookmarks */
    margin-left: -200px;
    margin-bottom: 0;

    width: 250px;
    min-height: 40px;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    text-align: left;
  }

  .bookmark:first-child {
    margin-left: 0;
  }

  .bookmark.finished {
    background: linear-gradient(135deg, #4CAF50 0%, #45A049 100%);
    box-shadow:
      0 4px 10px rgba(0, 0, 0, 0.35),
      0 8px 20px rgba(0, 0, 0, 0.25),
      0 12px 30px rgba(0, 0, 0, 0.2),
      0 0 20px rgba(76, 175, 80, 0.3);
  }

  .bookmark.running {
    background: linear-gradient(135deg, #FF9800 0%, #F57C00 100%);
    box-shadow:
      0 4px 10px rgba(0, 0, 0, 0.35),
      0 8px 20px rgba(0, 0, 0, 0.25),
      0 12px 30px rgba(0, 0, 0, 0.2),
      0 0 20px rgba(255, 152, 0, 0.3);
  }

  .bookmark.needs-interaction {
    background: linear-gradient(135deg, #F44336 0%, #D32F2F 100%);
    box-shadow:
      0 4px 10px rgba(0, 0, 0, 0.35),
      0 8px 20px rgba(0, 0, 0, 0.25),
      0 12px 30px rgba(0, 0, 0, 0.2),
      0 0 20px rgba(244, 67, 54, 0.4);
    animation: pulse 2s ease-in-out infinite;
  }

  @keyframes pulse {
    0%, 100% {
      box-shadow:
        0 4px 10px rgba(0, 0, 0, 0.35),
        0 8px 20px rgba(0, 0, 0, 0.25),
        0 12px 30px rgba(0, 0, 0, 0.2),
        0 0 20px rgba(244, 67, 54, 0.4);
    }
    50% {
      box-shadow:
        0 4px 10px rgba(0, 0, 0, 0.35),
        0 8px 20px rgba(0, 0, 0, 0.25),
        0 12px 30px rgba(0, 0, 0, 0.2),
        0 0 30px rgba(244, 67, 54, 0.6);
    }
  }

  .bookmark-text {
    font-weight: 600;
    font-size: 12px;
    letter-spacing: 0.3px;
    word-wrap: break-word;
    white-space: wrap;
    line-height: 1.2;
    padding-left: 60px;
    padding-right: 40px;

  }

  .no-branches {
    background: rgba(74, 144, 226, 0.9);
    color: white;
    padding: 8px 16px;
    border-radius: 4px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }
`;

export const render = ({ output }) => {
  if (!output || output.trim() === "") {
    return null; // Don't show anything if no windows
  }

  const windows = output
    .trim()
    .split("\n")
    .filter(line => line)
    .map(line => {
      const [index, name, info, active, claudeState] = line.split("|");
      // Replace underscores with spaces in branch/worktree names
      const formattedInfo = info.replace(/[_-]/g, " ");
      return {
        index,
        name,
        info: formattedInfo,
        active: active === "1",
        claudeState: claudeState || "inactive"
      };
    });

  return (
    <div className="bookmark-container">
      {windows.map((window, i) => {
        const classes = ['bookmark'];

        // Priority: needs_interaction > running > finished > inactive (blue)
        if (window.claudeState === 'needs_interaction') {
          classes.push('needs-interaction');
        } else if (window.claudeState === 'running') {
          classes.push('running');
        } else if (window.claudeState === 'finished') {
          classes.push('finished');
        }
        // else: stays blue (default .bookmark style)

        return (
          <div key={i} className={classes.join(' ')}>
            <span className="bookmark-text">
              {window.index}: {window.info}
            </span>
          </div>
        );
      })}
    </div>
  );
};
