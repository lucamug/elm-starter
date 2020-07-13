module Starter.SnippetCss exposing (..)


noJsAndLoadingNotifications : String -> String
noJsAndLoadingNotifications classNotification =
    """
.""" ++ classNotification ++ """ 
    { padding: 20px
    ; background-color: rgba(255,255,255,0.7)
    ; color: black
    ; width: 100%
    ; text-align: center
    ; position: fixed
    ; top: 0
    ; left: 0
    ; z-index: 1;
    }
"""
