;; Walking through eintr
(length '(1 2 3))
'(this is a quoted list)

(car '(olivia liam ryan))
(cdr '(olivia liam ryan))
(cons 'pine '(fir oak maple))

(nthcdr 2 '(pine fir oak maple))
(nthcdr 3 '(pine fir oak maple))
(nthcdr 4 '(pine fir oak maple))

(nth 0 '(olivia liam ryan))
(nth 2 '(olivia liam ryan))

(setq fam '(olivia liam ryan))
fam
(setcar fam 'doofus)
fam

(defun foo (a b c) (/ a b c))
(foo 1 2 3)

(cons "another place"
      '("a piece of text" "previous piece"))

(setq birdteams '(ravens seahawks))
birdteams
(setq morebirdteams '(eagles falcons cardinals))
(setq allbirdteams (append morebirdteams birdteams))
(setcdr allbirdteams '(cowboys giants redskins))
allbirdteams
(setcar allbirdteams 'losers)
allbirdteams

(cons "we reflect on"
      '("the effort that brought us" "this food"))

     (defun test-zap-to-char (arg char)
       "Kill up to and including ARG'th occurrence of CHAR.
     Case is ignored if `case-fold-search' is non-nil in the current buffer.
     Goes backward if ARG is negative; error if CHAR not found."
       (interactive "p\ncZap to char: ")
       (if (char-table-p translation-table-for-input)
           (setq char (or (aref translation-table-for-input char) char)))
       (kill-region (point) (progn
                              (search-forward (char-to-string char)
                                              nil nil arg)
                              (point))))
