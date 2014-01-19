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

myKeys c = mkKeymap c $
	[ ("M-<Return>", spawn $ XMonad.terminal c)
	, ("<XF86AudioRaiseVolume>", spawn "amixer -D pulse set Master 5%+ unmute")
	, ("<XF86AudioLowerVolume>", spawn "amixer -D pulse set Master 5%- unmute")
	, ("<XF86AudioMute>", spawn "amixer -D pulse set Master toggle")
	, ("M-g", spawn "google-chrome")
	, ("M-q", spawn "dm-tool lock")
	, ("M-p", shellPrompt defaultXPConfig)
  , ("M-m", windows W.focusMaster)
  , ("M-s", windows W.swapMaster)
  , ("M-u", focusUrgent)
  , ("M-S-s", withFocused $ windows . W.sink)
	]

main = do
  xmproc <- spawnPipe "xmobar ~/.xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ defaultConfig
    { modMask = mod4Mask
    , keys = \c -> myKeys c `M.union` keys defaultConfig c
    , manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  layoutHook defaultConfig
    , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc }
    , terminal = "urxvt -e tmux"
    , normalBorderColor = "#000000"
    , focusedBorderColor = "#ffffff"
    , borderWidth = 0
    }
