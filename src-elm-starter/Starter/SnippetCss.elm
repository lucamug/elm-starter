module Starter.SnippetCss exposing (noJsAndLoadingNotifications)


noJsAndLoadingNotifications : String -> String
noJsAndLoadingNotifications classNotification =
    """
.""" ++ classNotification ++ """ 
    { padding: 20px
    ; background-color: rgba(255,255,255,0.7)
    ; pointer-events: none
    ; color: black
    ; width: 100%
    ; text-align: center
    ; position: fixed
    ; left: 0
    ; z-index: 1
    ; box-sizing: border-box
    }
"""
