import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet as W
import XMonad.Actions.CycleWS
import qualified Data.Map as M
import System.Exit
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import System.IO
import Graphics.X11.ExtraTypes.XF86

import XMonad.Prompt
import XMonad.Prompt.Shell

import XMonad.Hooks.UrgencyHook

import XMonad.Layout.SimplestFloat
import XMonad.Layout.FullMaximize
import XMonad.Layout.NoBorders

myKeys c = mkKeymap c $
	[ ("M-<Return>", spawn $ XMonad.terminal c)
	, ("<XF86AudioRaiseVolume>", spawn "amixer -D pulse set Master 5%+ unmute")
	, ("<XF86AudioLowerVolume>", spawn "amixer -D pulse set Master 5%- unmute")
	, ("<XF86AudioMute>", spawn "amixer -D pulse set Master toggle")
  , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 20")
  , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 20")
	, ("M-g", spawn "chromium")
	, ("M-q", spawn "i3lock")
	, ("M-p", shellPrompt defaultXPConfig)
  , ("M-m", windows W.focusMaster)
  , ("M-`", withFocused (sendMessage . maximizeRestore))
  , ("M-s", windows W.swapMaster)
  , ("M-u", focusUrgent)
  , ("M-S-s", withFocused $ windows . W.sink)
	]

myLayouts = maximize (noBorders simplestFloat) ||| Full ||| tiled
  where
    tiled = Tall nmaster delta ratio
    -- Default number of windows in the master pane
    nmaster = 1
    -- Percent of screen to incremet by when resizing panes
    delta = 3/100
    -- Default portion of the screen occupied by master pane
    ratio = 1/2

main = do
  xmproc <- spawnPipe "xmobar ~/.xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
    { modMask = mod4Mask
    , keys = \c -> myKeys c `M.union` keys defaultConfig c
    , manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  myLayouts
    , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc }
    , terminal = "urxvt -e tmux"
    , normalBorderColor = "#000000"
    , focusedBorderColor = "#ffffff"
    , borderWidth = 0
    }
