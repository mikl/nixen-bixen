/**
  Quick-tile the active window to 1/3 or 2/3 of the work area, full height.

  1/3 is floor(width/3); 2/3 takes the remainder so a left-third and a
  right-two-thirds meet without a gap.
*/
function tile(side, thirds) {
    const window = workspace.activeWindow;
    if (!window || window.specialWindow || !window.moveable || !window.resizeable) {
        return;
    }

    if (window.fullScreen) {
        window.fullScreen = false;
    }
    window.setMaximize(false, false);
    if (window.tile) {
        window.tile = null;
    }

    const area = workspace.clientArea(KWin.MaximizeArea, window);
    const one = Math.floor(area.width / 3);
    const width = thirds === 1 ? one : area.width - one;
    const x = side === "left" ? area.x : area.x + area.width - width;

    window.frameGeometry = {
        x: x,
        y: area.y,
        width: width,
        height: area.height,
    };
}

registerShortcut(
    "Window Quick Tile Left Third",
    "Quick Tile Window to the Left Third",
    "Meta+Ctrl+Shift+Left",
    function () {
        tile("left", 1);
    },
);
registerShortcut(
    "Window Quick Tile Right Third",
    "Quick Tile Window to the Right Third",
    "Meta+Ctrl+Shift+Right",
    function () {
        tile("right", 1);
    },
);
registerShortcut(
    "Window Quick Tile Left Two Thirds",
    "Quick Tile Window to the Left Two Thirds",
    "Meta+Left",
    function () {
        tile("left", 2);
    },
);
registerShortcut(
    "Window Quick Tile Right Two Thirds",
    "Quick Tile Window to the Right Two Thirds",
    "Meta+Right",
    function () {
        tile("right", 2);
    },
);
