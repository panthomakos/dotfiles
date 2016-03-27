import qualified Data.Map                     as M
import           Graphics.X11.ExtraTypes.XF86
import           System.Exit
import           System.IO
import           XMonad
import           XMonad.Actions.CycleWS
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import qualified XMonad.StackSet              as W
import           XMonad.Util.EZConfig
import           XMonad.Util.Run              (spawnPipe)

import           XMonad.Prompt
import           XMonad.Prompt.Shell

import           XMonad.Hooks.UrgencyHook

myKeys c = mkKeymap c $
    [ ("M-<Return>", spawn $ XMonad.terminal c)
    , ("<XF86AudioRaiseVolume>", spawn "amixer -D pulse set Master 5%+ unmute")
    , ("<XF86AudioLowerVolume>", spawn "amixer -D pulse set Master 5%- unmute")
    , ("<XF86AudioMute>", spawn "amixer -D pulse set Master toggle")
    , ("<XF86MonBrightnessUp>", spawn "xbacklight -inc 20")
    , ("<XF86MonBrightnessDown>", spawn "xbacklight -dec 20")
    , ("M-g", spawn "chrome")
    , ("M-q", spawn "i3lock")
    , ("M-p", shellPrompt defaultXPConfig)
    , ("M-m", windows W.focusMaster)
    , ("M-s", windows W.swapMaster)
    , ("M-u", focusUrgent)
    , ("M-S-s", withFocused $ windows . W.sink)
    ]

myManageHook = composeAll
  [ title =? "Authy" --> doFloat
  , manageDocks
  ]

myLayouts = Full ||| tiled
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
    , manageHook = myManageHook <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  myLayouts
    , handleEventHook = mconcat
                      [ docksEventHook
                      , handleEventHook defaultConfig ]
    , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn xmproc }
    , terminal = "urxvt -e tmux"
    , normalBorderColor = "#000000"
    , focusedBorderColor = "#ffffff"
    , borderWidth = 0
    }
