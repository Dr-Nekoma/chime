(use-modules
  (guix)
  (guix git-download)
  (guix build-system gnu)
  ((guix licenses) #:prefix license:)
  (gnu packages gnustep)
  (gnu packages llvm)
  (gnu packages pkg-config)
  (gnu packages rust-apps))

(define vcs-file?
  (or (git-predicate (current-source-directory))
    (const #t)))

(package
  (name "chime")
  (version "0.0-git")
  (source
    (local-file "." "chime-checkout"
      #:recursive? #t
      #:select? vcs-file?))
  (build-system gnu-build-system)
  (arguments
    (list
      #:phases
      #~(modify-phases %standard-phases
          (delete 'check)
          (delete 'configure)
          (replace 'build
            (lambda* (#:key inputs #:allow-other-keys)
              (invoke (string-append #+clang "/bin/clang")
                "-Wall"
                "-O2"
                "-pthread"
                "-fPIC"
                "-Wunused-command-line-argument"
                "-lobjc"
                "-lgnustep-base"
                "-fobjc-runtime=gnustep-2.0"
                ;; FIXME: add gnustep-base, because apparently it's not in guix
                ;(string-append "-I" #+gnustep-base "/include")
                ;(string-append "-L" #+gnustep-base "/lib")
                (string-append "-I" #+gnustep-make "/include")
                (string-append "-I" #+libobjc2 "/include")
                (string-append "-L" #+libobjc2 "/lib")
                "-I./Chime/Headers"
                "./Chime/VM+Instructions.m"
                "./Chime/VM.m"
                "./Chime/Stack.m"
                "./Chime/Utilities.m"
                "./Chime/Parser.m"
                "./Chime/Main.m"
                "-o" "chime")))
          (replace 'install
            (lambda* (#:key inputs #:allow-other-keys)
              (mkdir-p (string-append #$output "/bin"))
              (mkdir-p (string-append #$output "/share/"))
              (install-file "chime" (string-append #$output "/bin")))))))
  (native-inputs
    (list
      gnustep-make
      pkg-config
      just))
  (inputs
    (list
      clang
      libobjc2))
  (synopsis "Dr Nekoma's Stack-based VM")
  (home-page "https://github.com/Dr-Nekoma/RacketowerDB")
  (license license:expat)
  (description "Dr Nekoma's official Stack-based VM.  Currently a toy Stack-based VM."))
