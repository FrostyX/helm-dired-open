;;; helm-dired-open.el --- "Open with" dialog for helm   -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jakub Kadlčík

;; Author: Jakub Kadlčík <frostyx@email.cz>
;; URL: https://github.com/FrostyX/helm-dired-open
;; Version: 0.1-pre
;; Package-Requires: ((emacs "26.3"))
;; Keywords: comm, dired, open-with

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; An 'Open with' dialog for opening files in external applications from Dired.


;;; Code:

;;;; Customization

(defcustom helm-dired-open-extensions nil
  "Alist of extensions mapping to a programs to run them in.
Programs are Alists as-well, consisting of executable and description that is
going to be displayed in helm selection. The filename is appended after the
program executable."
  :type '(alist
          :key-type (string :tag "Extension")
          :value-type
          (alist
           :key-type (string :tag "Program")
           :value-type (string :tag "Description")))
  :group 'helm-dired-open)

;;;; Commands

;;;###autoload
(defun helm-dired-open ()
  "Provide an 'Open with' dialog for opening files in external applications
from Dired. Such dialogs are commonly known from GUI file managers, when
right-clicking a file.

Configure your filetype to programs associations in
`helm-dired-open-extensions'. If any association is found, this function
fallback to simply running `dired-open-file'."
  (interactive)
  (let* ((source (helm-dired-open--source))
		 (candidates (alist-get 'candidates source)))
	(if candidates
		(helm :sources source)
	  (dired-open-file))))

;;;; Functions

;;;;; Private

(defun helm-dired-open--dired-file-extension ()
  "Return the extension of the currently selected file in Dired."
  (file-name-extension (dired-get-file-for-visit)))

(defun helm-dired-open--candidates ()
  "Return the Helm candidates for the currently selected file in Dired."
  (let* ((extension (helm-dired-open--dired-file-extension))
         (associations (cdr (assoc extension helm-dired-open-extensions))))
    (mapcar
     (lambda (pair)
       (cons (cdr pair) (car pair)))
     associations)))

(defun helm-dired-open--source ()
  "Helm source providing a list of programs that can open a file"
  `((name . "Open with")
    (candidates . ,(helm-dired-open--candidates))
    (action . ,'helm-dired-open--action)))

(defun helm-dired-open--action (candidate)
  "Use the selected candidate executable to open a file."
  (let* ((extension (helm-dired-open--dired-file-extension))
         (dired-open-extensions (list (cons extension candidate))))
    (dired-open-by-extension)))

;;;; Footer

(provide 'helm-dired-open)

;;; helm-dired-open.el ends here