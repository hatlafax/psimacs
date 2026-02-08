param (
    # General Switches
    [switch]$h                   = $false,
    [switch]$help                = $false,
    [switch]$run                 = $false,
    [switch]$state               = $false,
    [switch]$mingw               = $false,
    [switch]$ucrt                = $false,
    [switch]$clang               = $false,
    [switch]$uninstall           = $false,
    [switch]$force               = $false,
    [switch]$deactivate_all      = $false,

    # Feature Switches
    [switch]$conemu              = $false,
    [switch]$no_packages         = $false,
    [switch]$no_python           = $false,
    [switch]$no_python_update    = $false,
    [switch]$no_python_packages  = $false,
    [switch]$python_use_latest   = $false,
    [switch]$python_msi          = $false,
    [switch]$no_java             = $false,
    [switch]$no_langtool         = $false,
    [switch]$no_sumatrapdf       = $false,
    [switch]$no_pandoc           = $false,
    [switch]$no_plantuml         = $false,
    [switch]$no_reveal_js        = $false,
    [switch]$no_privatefile      = $false,
    [switch]$no_psimacsdocu      = $false,
    [switch]$no_fonts_install    = $false,
    [switch]$no_all_the_icons    = $false,
    [switch]$no_nerd_icons       = $false,
    [switch]$no_org_themes       = $false,
    [switch]$no_content          = $false,
    [switch]$no_npm              = $false,
    [switch]$no_whisper          = $false,
    [switch]$no_whisper_models   = $false,

    # Reversion Feature Switches: If set, the corresponding
    # feature switch gets reversed!
    [switch]$rev_conemu              = $false,
    [switch]$rev_packages            = $false,
    [switch]$rev_python              = $false,
    [switch]$rev_python_update       = $false,
    [switch]$rev_python_packages     = $false,
    [switch]$rev_java                = $false,
    [switch]$rev_langtool            = $false,
    [switch]$rev_sumatrapdf          = $false,
    [switch]$rev_pandoc              = $false,
    [switch]$rev_plantuml            = $false,
    [switch]$rev_reveal_js           = $false,
    [switch]$rev_privatefile         = $false,
    [switch]$rev_psimacsdocu         = $false,
    [switch]$rev_fonts_install       = $false,
    [switch]$rev_all_the_icons       = $false,
    [switch]$rev_nerd_icons          = $false,
    [switch]$rev_org_themes          = $false,
    [switch]$rev_content             = $false,
    [switch]$rev_npm                 = $false,
    [switch]$rev_whisper             = $false,
    [switch]$rev_whisper_models      = $false,

    # Switches for dedicated tasks
    [switch]$no_package_versions  = $false,
    [switch]$all_nerd_fonts       = $false,
    [switch]$all_whisper_models   = $false,
    [string[]]$whisper_models     = @("base", "medium"),
    [string]$whisper_release      = "whisper-bin-x64",
    [switch]$all_whisper_releases = $false,

    # Details Input
    [string]$python_requirements,
    [string]$python_version,
    [string]$java_version        = "21.35",
    [string]$sumatrapdf_version,
    [string]$psimacsbranch       = "master",
    [string]$username            = "YOUR NAME",
    [string]$useremail           = "YOUR EMAIL",
    [string]$calendarlatitude    = "0.0",
    [string]$calendarlongitude   = "0.0",
    [string]$calendarlocation    = "YOUR CITY, COUNTRY"
)

$whisper_model_list = @(
    "tiny",
    "tiny-q5_1",
    "tiny-q8_0",
    "tiny.en",
    "tiny.en-q5_1",
    "tiny.en-q8_0",
    "base",
    "base-q5_1",
    "base-q8_0",
    "base.en",
    "base.en-q5_1",
    "base.en-q8_0",
    "small",
    "small-q5_1",
    "small-q8_0",
    "small.en",
    "small.en-q5_1",
    "small.en-q8_0",
    "small.en-tdrz",
    "medium",
    "medium-q5_0",
    "medium-q8_0",
    "medium.en",
    "medium.en-q5_0",
    "medium.en-q8_0",
    "large-v1",
    "large-v2",
    "large-v2-q5_0",
    "large-v2-q8_0",
    "large-v3",
    "large-v3-q5_0",
    "large-v3-turbo",
    "large-v3-turbo-q5_0",
    "large-v3-turbo-q8_0"
)

if ($all_whisper_models)
{
    $whisper_models = $whisper_model_list
}

if (-not $run)
{
    if (-not $state) {
        $help = $true
    }
}

if ($help -or $h)
{
    echo "Usage: bootstrap.ps1 [options]"
    echo ""
    echo "This is the Psimacs bootstrap powershell script. Psimacs is special configuration"
    echo "of Emacs for working on Microsoft Windows."
    echo "Psimacs uses the MSYS2 Emacs. All additional tooling is readily installed by this"
    echo "bootstrap script. That is a lot of stuff and it takes at least 22 GByte of"
    echo "free disk space on your 'HOME' directory. It does all its installation in the 'psimacs'"
    echo "subfolder of the 'HOME'directory. A proper working installation of Git is required. It"
    echo "must be accesible from the powershell prompt used for running this script."
    echo ""
    echo "The following set of tools gets installed by this script:"
    echo ""
    echo "      ConEmu       : An optional terminal for windows. See option '-conemu'."
    echo "      Java         : Java is needed for 'LanguageTool' and for 'PlantUML'. See options '-no_java' and '-java_version'."
    echo "      LanguageTool : This is a multi-lingual grammer and spell checker. See option '-no_langtool'."
    echo "      Msys2        : Unix environment for Windows. This is the backbone of the installation."
    echo "                     You can install either MINGW64, UCRT64 or CLANG64 environments. Howerver, currently"
    echo "                     only the MINGW64 environment works without hassle."
    echo "                     See options '-mingw', '-ucrt', '-clang', or '-no_packages'." 
    echo "      Pandoc       : Pandoc is a universal document converter. See option '-no_pandoc'."
    echo "      plantUML     : PlantUML is a UML and diagram drawing tool. See option '-no_plantuml'."
    echo "      Psimacs      : This is the actual Psimacs Emacs configuration. The central peace of code."
    echo "      Python       : Psimacs builds around of Windows Python instead of the MSYS2 Python version."
    echo "                     Many tools are not compatible to the MSYS2 Python version."
    echo "                     The bootstrapping operation installs the latest Python version and setup"
    echo "                     a virtual Python environment into which many Python packages gets installed."
    echo "                     The list of these packages can be found in the 'Requirements.txt' file found"
    echo "                     Psimacs assets Python subdirectory."
    echo "                     See options '-no_python', '-no_python_update', '-no_python_packages', and '-python'." 
    echo "      SumatraPDF   : Psimacs uses the SumatryPDF viewer. See options '-no_sumatrapdf' and 'sumatrapdf_version'."
    echo "      Ghostscript  : Ghostscript is an interpreter for the PostScript language and PDF files. Installed via MSYS2."
    echo "      GraphViz     : GraphViz is graph visualization software. Installed via MSYS2."
    echo "      Cmake        : Cmake is the de-facto standard for building C++. Installed via MSYS2."
    echo "      Doxygen      : Doxygen is a documentation generator from source code. Installed via MSYS2."
    echo "      Hugo         : Hugo is the world's fastest framework for building websites. Installed via MSYS2."
    echo "      Reveal.js    : Reveal.js is an open source HTML presentation framework. It enables anyone with a"
    echo "                     web browser to create beautiful presentations for free."
    echo "      Hunspell     : Hunspell is a popular spell checking tool. Installed via MSYS2."
    echo "      ASpell       : ASpell is another popular spell checking tool. Installed via MSYS2."
    echo "      7zip         : 7-Zip is a file archiver with a high compression ratio.Installed via MSYS2."
    echo "      AStyle       : Artistic Style is a source code indenter, formatter, and beautifier for the C++"
    echo "                     programming language. Installed via MSYS2."
    echo "      ripgrep      : Ripgrep is a line-oriented search tool that recursively searches the current"
    echo "                     directory for a regex pattern. Installed via MSYS2."
    echo "      SciTE        : SciTE is an editor with facilities for building and running programs. Installed via MSYS2."
    echo "      fd           : This is a simple, fast and user-friendly alternative to find. Installed via MSYS2."
    echo "      nerd-fonts   : Iconic font aggregator, collection, and patcher. Psimacs uses the Hack fonts. Installed via MSYS2."
    echo "      texlive      : Provides a comprehensive full TeX system. Installed via MSYS2."
    echo "      Gcc          : The Gnu Compiler Collection. Installed via MSYS2."
    echo "      Clang        : The Clang compiler. Installed via MSYS2."
    echo "      Whisper      : Install the speech recognition engine Whisper."
    echo ""
    echo "Attention: This script does not perform any task withoud specification of the '-run' option!"
    echo ""
    echo "Important:"
    echo "      1) A Git installation is expected to exists on the target machine."
    echo "      2) Remove the MAX_PATH Limitation"
    echo "              Windows historically has limited path lengths to 260 characters."
    echo "              This means that pathes longer than 260 characters lead to errors"
    echo "              and are not resolved."
    echo "              This limitation can be expanded to approximately 32,000 characters."
    echo "              Your administrator will need to activate the 'Enable Win32 long paths'"
    echo "              group policy, or set 'LongPathsEnabled' to 1 in the registry key"
    echo "              HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem."
    echo "      3) A minor Python version cannot be installed if it is already installed on the machine."
    echo "         E.g. if you have 3.11.x already installed somewhere, the installation of the private Psimacs"
    echo "         Python version will fail. Either uninstall a previous Python version or copy the existing"
    echo "         Python installation into the Psimacs directory, i.e. \$HOME\psimacs\Python311."
    echo ""
    echo "Additionally, the script allows the complete deinstallation of the Psimacs envrironment. Python gets deinstalled"
    echo "properly and the virtual Python environment as well as Psimacs itself are only removed on special request with the"
    echo "'-force' option."
    echo ""
    echo "Options:"
    echo "      -h, -help           : Show this help."
    echo "      -run                : This script does nothing without setting the -run option!"
    echo "      -state              : Show the settings of all options and does nothing. Option '-run' is not necessary for use."
    echo "      -deactivate_all     : All feature are deactivated. No installation happens. Use options '-rev_*' to reactivate"
    echo "                            a features. That is useful, e.g. if you want to post install a feature."
    echo "    MSYS2"
    echo "      -mingw              : Install the MINGW64 MSYS2 environment. Recommended and the current default."
    echo "      -ucrt               : Install the UCRT64 MSYS2 environment. The future, but fails on Emacs's zmq package needed for jupyter."
    echo "      -clang              : Install the CLANG64 MSYS2 environment. Also fails on Emacs's zmq package."
    echo "      -no_packages        : Do not install any MSYS2 packages. Mainly for development purpose." 
    echo "      -all_nerd_fonts     : Install all available nerd fonts. Otherwise only firacode, hack, and inconsolata nerd fonts gets installed."
    echo "      -no_npm             : Do not install the Node.js package, providing command npm."
    echo "      -conemu             : Additionally install the ConEmu terminal."
    echo "    Python"
    echo "      -no_python          : Do not install Python."
    echo "      -python_use_latest  : Use the latest python version. Otherwise the version Python 3.11.9 is currently used."
    echo "                            The latest Python version might not work. Not all package wheels are already available."
    echo "      -python_msi         : Use the official msi installer from www.python.org. Otherwise the Python package is taken"
    echo "                            from https://github.com/astral-sh/python-build-standalone. It is not recommended to use the"
    echo "                            msi installer from www.pytho.org because it forces you to properly uninstall any Python version"
    echo "                            with the same major.minor version installed on your computer, which typically is quite a hassle."
    echo "      -no_python_update   : If Python is already installed, this options allows the suppression of Python updates."
    echo "      -no_python_packages : Do not install the the Psimacs defined Python package requirements."
    echo "      -python_version     : The Python version number in the format 'N.M.B' that should be installed. Default is latest"
    echo "                            if flage 'python_use_latest' is defined. Otherwise the Python 3.11.9 is currently used."
    echo "      -python_requirements: Path to alternative 'requirements.txt' to use instead of the one from the 'assets' directory."
    echo "    Java"
    echo "      -no_java             : Do not install OpenJDK JDK."
    echo "      -java_version        : The Java version number and the revision: 'N.M'"
    echo "    Tools"
    echo "      -no_langtool         : Do not install LangTool spell and grammar checker."
    echo "      -no_sumatrapdf       : Do not install the SumatraPDF viewer."
    echo "      -sumatrapdf_version  : The SumatraPDF viewer version number in the format 'N.M.B' that should be installed. Default is latest."
    echo "      -no_pandoc           : Do not install the Pandoc document converter."
    echo "      -no_plantuml         : Do not install the PlantUML tool."
    echo "      -no_reveal_js        : Do not install the reveal.js repository. This is not necessary for using of Reveal in Psimacs:"
    echo "                             Lookup Psimacs variable org-re-reveal-root or option REVEAL_ROOT for informations."
    echo "      -no_whisper          : Do not install the Whisper speech recognition engine."
    echo "      -whisper_release     : Defaults to 'whisper-bin-x64'. Alternatives are 'whisper-blas-bin-x64', 'whisper-cublas-11.8.0-bin-x64', 'whisper-cublas-12.4.0-bin-x64'"
    echo "      -all_whisper_releases: Download all releases but only the '$whisper_release' gets installed."
    echo "      -no_whisper_models   : Do not install the Whisper gmll models from Hugging Face."
    echo "      -all_whisper_models  : Install all whisper models, which adds up to 23.4 GByte:"
    foreach ($model in  $whisper_model_list) {
        echo "                            - $model"
    }
    echo "    Psimacs"
    echo "      -psimacsbranch      : The specific branch, tag or commit to clone. Currently this defaults to the 'master'"
    echo "                            branch of Psimacs, which is compatible with Emacs 30.2."
    echo "      -no_privatefile     : Do not create the 'private' directectory with an 'init-private.el' file."
    echo "      -no_psimacsdocu     : Do not create desktop shortcuts to the HTML documentation files."
    echo "      -username           : The user name written to the 'init-private.el' file."
    echo "      -useremail          : The user email written to the 'init-private.el' file."
    echo "      -calendarlatitude   : The user latitude used for the calender written to the 'init-private.el' file."
    echo "      -calendarlongitude  : The user longitude used for the calender written to the 'init-private.el' file."
    echo "      -calendarlocation   : The user place used for the calender location."
    echo "      -no_package_versions: Remove the 'straight/versions/default.el' file. In that case Psimacs installs the"
    echo "                            most recent packages. Recommended only for experts."
    echo "      -no_fonts_install   : Do not install any fonts in the Windows system."
    echo "      -all_nerd_fonts     : Install all of the Nerd fonts, instead of a subset."
    echo "      -no_all_the_icons   : Do not install the 'alltheicons' TTF fonts."
    echo "      -no_nerd_icons      : Do not install the 'nerdicons' TTF fonts."
    echo "      -no_org_themes      : Do not install the org themes."
    echo "      -no_content         : Do not create the boilerplate content folder."
    echo "    Deinstallation"
    echo "      -uninstall          : Uninstall all but the virtual Python environment and Psimacs itself."
    echo "      -force              : Additionally uninstall the virtual Python environment and Psimacs itself. Also needs option '-uninstall'."
    echo ""
    echo "    Feature Reversion     : If a '-rev_*' reversion switch is set, the corresponding feature switch is reversed!"
    echo "      -rev_conemu             :  Reverses '-conemu'."
    echo "      -rev_packages           :  Reverses '-no_packages'."
    echo "      -rev_python             :  Reverses '-no_python'."
    echo "      -rev_python_update      :  Reverses '-no_python_update'."
    echo "      -rev_python_packages    :  Reverses '-no_python_packages'."
    echo "      -rev_java               :  Reverses '-no_java'."
    echo "      -rev_langtool           :  Reverses '-no_langtool'."
    echo "      -rev_sumatrapdf         :  Reverses '-no_sumatrapdf'."
    echo "      -rev_pandoc             :  Reverses '-no_pandoc'."
    echo "      -rev_plantuml           :  Reverses '-no_plantuml'."
    echo "      -rev_reveal_js          :  Reverses '-no_reveal_js'."
    echo "      -rev_privatefile        :  Reverses '-no_privatefile'."
    echo "      -rev_psimacsdocu        :  Reverses '-no_psimacsdocu'."
    echo "      -rev_fonts_install      :  Reverses '-no_fonts_install'."
    echo "      -rev_all_the_icons      :  Reverses '-no_all_the_icons'."
    echo "      -rev_nerd_icons         :  Reverses '-no_nerd_icons'."
    echo "      -rev_org_themes         :  Reverses '-no_org_themes'."
    echo "      -rev_content            :  Reverses '-no_content'."
    echo "      -rev_npm                :  Reverses '-no_npm'."
    echo "      -rev_whisper            :  Reverses '-no_whisper'."
    echo "      -rev_whisper_models     :  Reverses '-no_whisper_models'."
    echo ""
    echo "Examples:"
    echo "      bootstrap.ps1 -help"
    echo "      bootstrap.ps1 -run"
    echo "      bootstrap.ps1 -run -conemu -ucrt"
    echo "      bootstrap.ps1 -run -conemu -mingw -no_packages -python 3.11.9 -java_version 21.35"
    echo "      bootstrap.ps1 -run -mingw -all_nerd_fonts -python_use_latest -username \"Tobi Talbot\" -useremail \"tobi4242@gmail.com\" -calendarlatitude \"42.123\" -calendarlongitude \"2.987\" -calendarlocation \"Montreal, Canada\""
    echo "      bootstrap.ps1 -run -mingw -no_packages -no_java -no_langtool -no_sumatrapdf -no_pandoc -no_plantuml -no_privatefile -no_fonts_install -no_org_themes -no_content -python_requirements .\requirements.txt"
    echo ""
    echo "Information:"
    echo "      In case that the powershell script does not run, two reasons may be involved:"
    echo ""
    echo "      1. Set a proper execution policy for powershell scripts with respect to the user profile."
    echo "      2. Downloaded powershell scripts are not executed. They need to be unlocked."
    echo ""     
    echo "      The following steps might work for you:"
    echo '      Get-ExecutionPolicy -list'
    echo '      Set-ExecutionPolicy -ExecutionPolicy unrestricted -Scope CurrentUser'
    echo '      Unblock-File -Path .\bootstrap.ps1'
    echo '      .\bootstrap.ps1 -help'
    echo ""
    echo "ToDo:"
    echo "  Missing installation of font file Symbola.otf"
    echo "  https://dn-works.com/wp-content/uploads/2020/UFAS-Fonts/Symbola.zip"
    return
}

#
# Handle '-deactivate_all' option
#
if ($deactivate_all) {
    $conemu              = $false
    $no_packages         = $true
    $no_python           = $true
    $no_python_update    = $true
    $no_python_packages  = $true
    $no_java             = $true
    $no_langtool         = $true
    $no_sumatrapdf       = $true
    $no_pandoc           = $true
    $no_plantuml         = $true
    $no_reveal_js        = $true
    $no_privatefile      = $true
    $no_psimacsdocu      = $true
    $no_fonts_install    = $true
    $no_all_the_icons    = $true
    $no_nerd_icons       = $true
    $no_org_themes       = $true
    $no_content          = $true
    $no_npm              = $true
    $no_whisper          = $true
    $no_whisper_models   = $true
}

#
# Reverse Switches if requested
#
if ($rev_conemu            ) { $conemu              = -not $conemu              }
if ($rev_packages          ) { $no_packages         = -not $no_packages         }
if ($rev_python            ) { $no_python           = -not $no_python           }
if ($rev_python_update     ) { $no_python_update    = -not $no_python_update    }
if ($rev_python_packages   ) { $no_python_packages  = -not $no_python_packages  }
if ($rev_java              ) { $no_java             = -not $no_java             }
if ($rev_langtool          ) { $no_langtool         = -not $no_langtool         }
if ($rev_sumatrapdf        ) { $no_sumatrapdf       = -not $no_sumatrapdf       }
if ($rev_pandoc            ) { $no_pandoc           = -not $no_pandoc           }
if ($rev_plantuml          ) { $no_plantuml         = -not $no_plantuml         }
if ($rev_reveal_js         ) { $no_reveal_js        = -not $no_reveal_js        }
if ($rev_privatefile       ) { $no_privatefile      = -not $no_privatefile      }
if ($rev_psimacsdocu       ) { $no_psimacsdocu      = -not $no_psimacsdocu      }
if ($rev_fonts_install     ) { $no_fonts_install    = -not $no_fonts_install    }
if ($rev_all_the_icons     ) { $no_all_the_icons    = -not $no_all_the_icons    }
if ($rev_nerd_icons        ) { $no_nerd_icons       = -not $no_nerd_icons       }
if ($rev_org_themes        ) { $no_org_themes       = -not $no_org_themes       }
if ($rev_content           ) { $no_content          = -not $no_content          }
if ($rev_npm               ) { $no_npm              = -not $no_npm              }    
if ($rev_whisper           ) { $no_whisper          = -not $no_whisper          }
if ($rev_whisper_models    ) { $no_whisper_models   = -not $no_whisper_models   }

#
# Are we running with Admin rights?
#
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($python_requirements) {
    $python_requirements = Convert-Path -LiteralPath "$python_requirements"
}

if ($state) {
    echo "General options:"
    echo "  run                 = $run"
    echo "  state               = $state"
    echo "  mingw               = $mingw"
    echo "  ucrt                = $ucrt"
    echo "  clang               = $clang"
    echo "  uninstall           = $uninstall"
    echo "  force               = $force"
    echo "  deactivate_all      = $deactivate_all"
    echo ""
    echo "Feature switches:"
    echo "  conemu              = $conemu"
    echo "  no_packages         = $no_packages"
    echo "  no_python           = $no_python"
    echo "  no_python_update    = $no_python_update"
    echo "  no_python_packages  = $no_python_packages"
    echo "  python_use_latest   = $python_use_latest"
    echo "  python_msi          = $python_msi"
    echo "  no_java             = $no_java"
    echo "  no_langtool         = $no_langtool"
    echo "  no_sumatrapdf       = $no_sumatrapdf"
    echo "  no_pandoc           = $no_pandoc"
    echo "  no_plantuml         = $no_plantuml"
    echo "  no_reveal_js        = $no_reveal_js"
    echo "  no_privatefile      = $no_privatefile"
    echo "  no_psimacsdocu      = $no_psimacsdocu"
    echo "  no_fonts_install    = $no_fonts_install"
    echo "  no_all_the_icons    = $no_all_the_icons"
    echo "  no_nerd_icons       = $no_nerd_icons"
    echo "  no_org_themes       = $no_org_themes"
    echo "  no_content          = $no_content"
    echo "  no_npm              = $no_npm"
    echo "  no_whisper          = $no_whisper"
    echo "  no_whisper_models   = $no_whisper_models"
    echo ""
    echo "Reversion feature switches"
    echo "  rev_conemu          = $rev_conemu"
    echo "  rev_packages        = $rev_packages"
    echo "  rev_python          = $rev_python"
    echo "  rev_python_update   = $rev_python_update"
    echo "  rev_python_packages = $rev_python_packages"
    echo "  rev_java            = $rev_java"
    echo "  rev_langtool        = $rev_langtool"
    echo "  rev_sumatrapdf      = $rev_sumatrapdf"
    echo "  rev_pandoc          = $rev_pandoc"
    echo "  rev_plantuml        = $rev_plantuml"
    echo "  rev_reveal_js       = $rev_reveal_js"
    echo "  rev_privatefile     = $rev_privatefile"
    echo "  rev_psimacsdocu     = $rev_psimacsdocu"
    echo "  rev_fonts_install   = $rev_fonts_install"
    echo "  rev_all_the_icons   = $rev_all_the_icons"
    echo "  rev_nerd_icons      = $rev_nerd_icons"
    echo "  rev_org_themes      = $rev_org_themes"
    echo "  rev_content         = $rev_content"
    echo "  rev_npm             = $rev_npm"
    echo "  rev_whisper         = $rev_whisper"
    echo "  rev_whisper_models  = $rev_whisper_models"
    echo ""
    echo "Switches for dedicated tasks:"
    echo "  no_package_versions = $no_package_versions"
    echo "  all_nerd_fonts      = $all_nerd_fonts"
    echo "  all_whisper_releases= $all_whisper_releases"
    echo "  all_whisper_models  = $all_whisper_models"
    echo ""
    echo "Detail settings:"
    echo "  python_requirements = $python_requirements"
    echo "  python_version      = $python_version"
    echo "  java_version        = $java_version"
    echo "  sumatrapdf_version  = $sumatrapdf_version"
    echo "  psimacsbranch       = $psimacsbranch"
    echo "  username            = $username"
    echo "  useremail           = $useremail"
    echo "  calendarlatitude    = $calendarlatitude"
    echo "  calendarlongitude   = $calendarlongitude"
    echo "  calendarlocation    = $calendarlocation"
    echo "  whisper_release     = $whisper_release"
    echo ""
    echo "The following whisper models gets installed:"
    foreach ($model in  $whisper_models) {
    echo "  - $model"
    }

    return
}

#
# Uninstallation
#
if ($uninstall)
{
    echo "Uninstalling Psimacs ..."

    #
    # Test for HOME environment variable. If it does not exist
    # we can't uninstall anything and we leave the script.
    #
    if (-not $env:HOME)
    {
        echo "No HOME environment variable defined. Prematurely leaving script!"
        return
    }

    #
    # Define the Psimacs directory
    #
    $psimacs = "$env:HOME\psimacs"
    $psimacs = $psimacs.Replace('/', '\')

    if ( ! (test-path -PathType container $psimacs) )
    {
        echo "No $psimacs directory found. Prematurely leaving script!"
        return
    }

    #
    # Deinstallation of Python
    #
    if ($python_msi)
    {
        $dirs = Get-ChildItem "$psimacs\Python*" -Directory

        foreach ($dir in $dirs)
        {
            if ($dir -match 'Python(?<major>\d)(?<minor>\d+)$')
            {
                $PyMajor = $Matches.major
                $PyMinor = $Matches.minor

                $python = "CPython-${PyMajor}.${PyMinor}"

                echo "Found $python installation in $dir ..."

                #
                # Lookup the uninstaller for that Python version
                #
                $key = "registry::HKEY_CURRENT_USER\SOFTWARE\Classes\Installer\Dependencies\$python"
                if (Test-Path -Path "$key")
                {
                    $key = "registry::\HKEY_CURRENT_USER\SOFTWARE\Classes\Installer\Dependencies\$python\Dependents\*"
                    $subkeys = Get-ChildItem -Path "$key"

                    foreach ($subkey in $subkeys)
                    {
                        if ($subkey -match '^.*\\(?<hash_key>\{.+\})$')
                        {
                            $hash_key = $Matches.hash_key

                            $key = "registry::\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$hash_key"
                            if (Test-Path -Path "$key")
                            {
                                try {
                                    $uninstall_cmd = (Get-ItemProperty -Path "$key" -Name "QuietUninstallString").QuietUninstallString

                                    if ($uninstall_cmd -match '^"(?<cmd>.*)"\s+(?<args>.*)$')
                                    {
                                        $uninstall_cmd  = $Matches.cmd
                                        $uninstall_args = $Matches.args

                                        echo "$uninstall_cmd"
                                        echo "$uninstall_args"

                                        Start-Process "$uninstall_cmd" -NoNewWindow -Wait -ArgumentList "$uninstall_args"
                                    }
                                }
                                catch
                                {
                                    echo "Uninstallation of $python failed!"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    #
    # Deinstallation of all tools but not the virtual Python environment and not Psimacs itself!
    #
    $dirs = Get-ChildItem "$psimacs\*" -Directory

    foreach ($dir in $dirs)
    {
        if ($dir -match 'Python\d+_0|psimacs$')
        {
            if (-not $force)
            {
                echo "Excluding directory $dir from uninstallation..."
            }
        }
        else
        {
            echo "Removing directory $dir recursively..."
            Remove-Item -Recurse -Force "$dir"
        }
    }

    if ( Test-Path "$psimacs\psimacs.cmd" -PathType Leaf )
    {
        Remove-Item -Force "$psimacs\psimacs.cmd"
    }

    #
    # Deinstallation of the virtual Python environment and Psimacs itself.
    #
    if ($force)
    {
        $dirs = Get-ChildItem "$psimacs\*" -Directory

        foreach ($dir in $dirs)
        {
            if ($dir -match 'Python\d+_0|psimacs$')
            {
                echo "Removing directory $dir recursively..."
                Remove-Item -Recurse -Force "$dir"
            }
        }

        if ( test-path -PathType container $psimacs )
        {
            echo "Finally removing root directory $psimacs ..."
            Remove-Item -Recurse -Force "$psimacs"
        }
    }

    #
    # Remove shortcuts from desktop
    #
    $Shell   = New-Object -comObject WScript.Shell
    $Desktop = $Shell.SpecialFolders("Desktop")

    $shortcuts = @()

    $shortcuts += "$Desktop\Psimacs MSYS2 MINGW 64-bit.lnk"
    $shortcuts += "$Desktop\Psimacs MSYS2 MINGW 64-bit.lnk"
    $shortcuts += "$Desktop\Psimacs ConEmu MSYS2 MINGW 64-bit.lnk"

    $shortcuts += "$Desktop\Psimacs MSYS2 UCRT 64-bit.lnk"
    $shortcuts += "$Desktop\Psimacs MSYS2 UCRT 64-bit.lnk"
    $shortcuts += "$Desktop\Psimacs ConEmu MSYS2 UCRT 64-bit.lnk"

    $shortcuts += "$Desktop\Psimacs MSYS2 CLANG 64-bit.lnk"
    $shortcuts += "$Desktop\Psimacs MSYS2 CLANG 64-bit.lnk"
    $shortcuts += "$Desktop\Psimacs ConEmu MSYS2 CLANG 64-bit.lnk"

    $shortcuts += "$Desktop\Psimacs Server.lnk"
    $shortcuts += "$Desktop\Psimacs Client.lnk"

    $shortcuts += "$Desktop\Psimacs Documentation.lnk"
    $shortcuts += "$Desktop\Psimacs Key Bindings.lnk"

    foreach ($shortcut in $shortcuts)
    {
        if ( Test-Path "$shortcut" -PathType Leaf )
        {
            echo "Removing shortcut $shortcut ..."
            Remove-Item -Force "$shortcut"
        }
    }

    return
}

if ( -not ($mingw -OR $ucrt -OR $clang))
{
    $mingw = $true
}

if ($mingw)
{
    if ($ucrt -OR $clang)
    {
        echo "Only one MSYS2 environment is allowed! Use either -mingw, -ucrt or -clang."
        return
    }
    echo "Working on MSYS2 environment MINGW64..."
}

if ($ucrt)
{
    if ($mingw -OR $clang)
    {
        echo "Only one MSYS2 environment is allowed! Use either -mingw, -ucrt or -clang."
        return
    }
    echo "Working on MSYS2 environment UCRT64..."
}

if ($clang)
{
    if ($mingw -OR $ucrt)
    {
        echo "Only one MSYS2 environment is allowed! Use either -mingw, -ucrt or -clang."
        return
    }
    echo "Working on MSYS2 environment CLANG64..."
}

#
# Precondition: check for windows git
#
#       We do not install git into the msys64, because it does
#       not work out of the box currently.
#

try
{
    git | Out-Null
    echo "Git is installed and accessible on the machine..."
}
catch [System.Management.Automation.CommandNotFoundException]
{
    echo "Git is not accessible but required. Install a proper Windows Git"
    echo "e.g. from https://git-scm.com/download/win"
    echo "Provided that you have installed git to 'c:\utils\Git'"
    echo "do add the 'c:\utils\Git\cmd' direcotry to your PATH variable!"
    return
}

#
# Precondition check for Python version if requested Python
#
if (-not $no_python)
{
    if ((-not $python_version) -and (-not $python_use_latest))
    {
        $python_version = "3.11.9"
    }

    if ($python_version)
    {
        if ($python_version -match '(?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+)')
        {
            $PyMajor = $Matches.major
            $PyMinor = $Matches.minor
            $PyBuild = $Matches.build

            if ($python_msi)
            {
                #
                # Remark: Python on Windows allows not to install separate build numbers.
                #         We therefore use the 'PythonXY' directory as used by many people.
                #
                $python_dir = "Python${PyMajor}${PyMinor}"
            }
            else
            {
                try
                {
                    $ProgressPreference = "silentlyContinue"

                    $githubLatestReleases = 'https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest'

                    $githubLatestRelease = (((Invoke-WebRequest -Uri $gitHubLatestReleases -UseBasicParsing) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern '-x86_64-pc-windows-msvc-install_only.tar.gz').Line
                    
                    $ProgressPreference = 'Continue'
                }
                catch
                {
                    echo "Could not determine Python version from 'https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest'!"
                    return 
                }

                $python_url =""
                $python_major_minor_requested = "${PyMajor}.${PyMinor}"
                $python_requested = $python_version

                $no_exact_match = $false

                $PyMajor_found = $PyMajor
                $PyMinor_found = $PyMinor
                $PyBuild_found = $PyBuild

                foreach ($e in $githubLatestRelease)
                {
                    if ($e -match '^.*cpython-(?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+)%.*$')
                    {
                        $PyMajor = $Matches.major
                        $PyMinor = $Matches.minor
                        $PyBuild = $Matches.build

                        $python_major_minor_build = "${PyMajor}.${PyMinor}.${PyBuild}"
                        $python_major_minor       = "${PyMajor}.${PyMinor}"

                        if ($python_major_minor_build -eq $python_version)
                        {
                            $python_url = $e
                            $no_exact_match = $false

                            $PyMajor_found = $PyMajor
                            $PyMinor_found = $PyMinor
                            $PyBuild_found = $PyBuild
                        }

                        if ( (-not $python_url) -and ($python_major_minor -eq $python_major_minor_requested) )
                        {
                            $python_url = $e
                            $no_exact_match = $true

                            $PyMajor_found = $PyMajor
                            $PyMinor_found = $PyMinor
                            $PyBuild_found = $PyBuild
                        }
                    }
                }

                if (-not $python_url)
                {
                    echo "Standalone Python does not provide the requested version ${python_requested}."
                    return 
                }

                if ($no_exact_match)
                {
                    $python_version = "${PyMajor_found}.${PyMinor_found}.${PyBuild_found}"
                    echo "Standalone Python does not provide the requested version ${python_requested}. Using ${python_version} instead."
                }

                #
                # Remark: Python on Windows allows not to install separate build numbers.
                #         With the standalone route we could, but we stick to the same
                #         pattern as in the msi case. 
                #         We therefore use the 'PythonXY' directory as used by many people.
                #
                $python_dir = "Python${PyMajor_found}${PyMinor_found}"
            }
        }
        else
        {
            echo "Invalid Python version given: RegExp format is '\d\.\d+\.\d+'."
            return
        }
    }
    else
    {
        if ($python_msi)
        {
            $baseuri = 'https://www.python.org/downloads/windows'

            try 
            {
                $ProgressPreference = "silentlyContinue"
                $response = Invoke-WebRequest -Uri $baseuri -UseBasicParsing
                $ProgressPreference = 'Continue'

                if ($response.Content -match '.*Latest Python \d+ Release - Python (?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+).*')
                {
                    $PyMajor = $Matches.major
                    $PyMinor = $Matches.minor
                    $PyBuild = $Matches.build

                    $python_version = "${PyMajor}.${PyMinor}.${PyBuild}"

                    #
                    # Remark: Python on Windows allows not to install separate build numbers.
                    #         We therefore use the 'PythonXY' directory as used by many people.
                    #
                    $python_dir = "Python${PyMajor}${PyMinor}"

                    echo "Found latest stable Python release $python_version"
                }
                else
                {
                    echo "No valid Python version could be determined. Please provide a version string"
                    echo "with option -python, like -python 3.11.9."
                    return
                }
            }
            catch
            {
                echo "Could identify the latest Python version number. Check for another Python version. Prematurely leaving script!"
                return
            }
        }
        else
        {
            try
            {
                $ProgressPreference = "silentlyContinue"

                $githubLatestReleases = 'https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest'

                $githubLatestRelease = (((Invoke-WebRequest -Uri $gitHubLatestReleases -UseBasicParsing) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern '-x86_64-pc-windows-msvc-install_only.tar.gz').Line
                
                $ProgressPreference = 'Continue'
            }
            catch
            {
                echo "Could not determine Python version from 'https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest'!"
                return 
            }

            [Int]$major_latest = 0
            [Int]$minor_latest = 0
            [Int]$build_latest = 0

            $python_url =""

            foreach ($e in $githubLatestRelease)
            {
                if ($e -match '^.*cpython-(?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+)%.*$')
                {
                    $PyMajor = $Matches.major
                    $PyMinor = $Matches.minor
                    $PyBuild = $Matches.build

                    [int]$major = [Int]${PyMajor}
                    [int]$minor = [Int]${PyMinor}
                    [int]$build = [Int]${PyBuild}

                    if ($major_latest -lt $major)
                    {
                        $major_latest = $major
                        $minor_latest = 0
                        $build_latest = 0

                        $python_url = $e
                    }

                    if ( ($major_latest -eq $major) -and ($minor_latest -lt $minor) )
                    {
                        $minor_latest = $minor
                        $build_latest = 0

                        $python_url = $e
                    }

                    if ( ($major_latest -eq $major) -and ($minor_latest -eq $minor) -and ($build_latest -lt $build) )
                    {
                        $build_latest = $build

                        $python_url = $e
                    }
                }
            }

            $PyMajor = $major_latest.ToString()
            $PyMinor = $minor_latest.ToString()
            $PyBuild = $build_latest.ToString()

            $python_version = "${PyMajor}.${PyMinor}.${PyBuild}"

            #
            # Remark: Python on Windows allows not to install separate build numbers.
            #         With the standalone route we could, but we stick to the same
            #         pattern as in the msi case. 
            #         We therefore use the 'PythonXY' directory as used by many people.
            #
            $python_dir = "Python${PyMajor}${PyMinor}"
        }
    }
}

#
# Precondition Java
#
if (-not $no_java)
{
    if ($java_version -match '(?<major>\d+)\.(?<revision>\d+)')
    {
        $JavaMajor = $Matches.major
        $JavaRev   = $Matches.revision

        $java_url = "https://download.java.net/openjdk/jdk${JavaMajor}/ri/openjdk-${JavaMajor}+${JavaRev}_windows-x64_bin.zip"
        $java_jdk = "jdk-$JavaMajor"
    }
    else
    {
        echo "Invalid Java OpenJDK version number: $java_version"
        return
    }
}

#
# Precondition check for SumatraPDF version if requested SumatryPDF
#
if (-not $no_sumatrapdf)
{
    if ($sumatrapdf_version)
    {
        if ($sumatrapdf_version -match '(?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+)')
        {
            $SumatraMajor = $Matches.major
            $SumatraMinor = $Matches.minor
            $SumatraBuild = $Matches.build
        }
        else
        {
            echo "Invalid SumatraPDF version version given: RegExp format is '\d\.\d+\.\d+'"
            return
        }
    }
    else
    {
        $baseuri = 'https://www.sumatrapdfreader.org/download-free-pdf-viewer'

        try 
        {
            $ProgressPreference = "silentlyContinue"
            $response = Invoke-WebRequest -Uri $baseuri -UseBasicParsing
            $ProgressPreference = 'Continue'

            if ($response.Content -match '.*SumatraPDF-(?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+)-64.zip.*')
            {
                $SumatraMajor = $Matches.major
                $SumatraMinor = $Matches.minor
                $SumatraBuild = $Matches.build

                $sumatrapdf_version = "${SumatraMajor}.${SumatraMinor}.${SumatraBuild}"

                echo "Found latest stable SumatraPDF release $sumatrapdf_version"
            }
            else
            {
                echo "No valid SumatraPDF version could be determined. Please provide a version string"
                echo "with option -sumatrapdf_version, like -sumatrapdf_version 3.4.6"
                return
            }
        }
        catch
        {
            echo "Could identify the latest SumatraPDF version number. Check for another SumatraPDF version. Prematurely leaving script!"
            return
        }
    }
}

#
# Test for HOME environment variable. If it does not exist
# create it in c:\User\[Environment]::UserName
#
if (-not $env:HOME)
{
    echo "Creating HOME environment variable..."

    $user = [Environment]::UserName
    echo $user
    [Environment]::SetEnvironmentVariable('HOME', "c:\home\$user", 'User')
}

#
# Define the Psimacs directory
#
$psimacs = "$env:HOME\psimacs"
$psimacs = $psimacs.Replace('/', '\')

#
# Create the $enc:HOME\psimacs directory if it does not exist
#
if ( ! (test-path -PathType container $psimacs) )
{
    echo "Creating $psimacs directory..."
    New-Item -ItemType Directory -Path $psimacs
}


#
# Go to the psimacs directory for further working
#
Set-Location -Path "$psimacs"

#
# Bootstrap msys64 into psimacs dir: Install
#
$msys64       = "$psimacs\msys64"
$msys64_bin   = "$msys64\usr\bin"

if ($mingw)
{
    $package_prefix = "mingw-w64-x86_64"
    $msys_env_bin   = "$msys64\mingw64\bin"
    $msys_env_share = "$msys64\mingw64\share"
    $msys_env_name  = "MINGW"
    $msys_env_icon  = "mingw64.ico"
    $msys_env_arg   = "mingw64"
}

if ($ucrt)
{
    $package_prefix = "mingw-w64-ucrt-x86_64"
    $msys_env_bin   = "$msys64\ucrt64\bin"
    $msys_env_share = "$msys64\ucrt64\share"
    $msys_env_name  = "UCRT"
    $msys_env_icon  = "ucrt64.ico"
    $msys_env_arg   = "ucrt64"
}

if ($clang)
{
    $package_prefix = "mingw-w64-clang-x86_64"
    $msys_env_bin   = "$msys64\clang64\bin"
    $msys_env_share = "$msys64\clang64\share"
    $msys_env_name  = "CLANG"
    $msys_env_icon  = "clang64.ico"
    $msys_env_arg   = "clang64"
}

if ( ! (Test-Path $msys64) )
{
    echo "Installing MSYS2 in $msys64 directory..."

    $msys64_installer = "msys2-base-x86_64-latest.sfx.exe"

    #
    # Download installer
    #
    if ( ! (Test-Path "$psimacs\$msys64_installer" -PathType Leaf) )
    {
        echo "Downloading $msys64_installer installer..."

        $msys64_installer_url = "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/$msys64_installer"
        
        try
        {
            $ProgressPreference = "silentlyContinue"
            Invoke-WebRequest -Uri $msys64_installer_url -UseBasicParsing -OutFile $msys64_installer
            $ProgressPreference = 'Continue'
        }
        catch
        {
            echo "Downloading of MSYS2 installer failed. Prematurely leaving script!"
            Set-Location -Path "$PSScriptRoot"
            return 
        }
    }

    #
    # Execute the msys64 installer
    #
    if ( Test-Path "$psimacs\$msys64_installer" -PathType Leaf )
    {
        echo "Running $msys64_installer installer..."

        & "$psimacs\$msys64_installer"
        Remove-Item "$psimacs\$msys64_installer"
    }
}

#
# Check for msys64
#
if ( ! (Test-Path $msys64) )
{
    echo "Expected path $msys64 could not be found. Leaving script!"
    return
}

#
# Bootstrap msys64 into psimacs dir: setup environment
#
$bash_exe     = "$msys64_bin\bash.exe"

$env:PATH   = "$msys64_bin;$env:PATH"

$env:CHERE_INVOKING  = 1
$env:MSYSTEM         = "${msys_env_name}64"
$env:MSYS2_PATH_TYPE = 'inherit'
$env:CONTITLE        = "MinGW ${msys_env_name} x64"


if (-not $no_packages )
{
    echo "Bootstrapping $msys64 ..."

    #
    # Bootstrap msys64 into psimacs dir: setup pacman
    #
    & $bash_exe --login -c "mkdir -p /var/cache/pacman/pkg"

    #
    # Bootstrap msys64 into psimacs dir: pacman update process
    #
    & $bash_exe --login -c "pacman -Syuu --noconfirm --needed --noprogressbar && ps -ef | grep 'dirmngr'   | grep -v grep | awk '{print `$2}' | xargs -r kill -9 && ps -ef | grep 'gpg-agent' | grep -v grep | awk '{print `$2}' | xargs -r kill -9"
    & $bash_exe --login -c "pacman -Syuu --noconfirm --needed --noprogressbar && ps -ef | grep 'gpg-agent' | grep -v grep | awk '{print `$2}' | xargs -r kill -9"

    #
    # Bootstrap msys64 into psimacs dir: install man pages
    #
    & $bash_exe --login -c "pacman --sync --noconfirm --needed man-db"

    #
    # Bootstrap msys64 into psimacs dir: install base development tools
    #
    & $bash_exe --login -c "pacman --sync --noconfirm --needed msys2-devel"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed base-devel"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed compression"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed Database"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-wget2"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed dos2unix"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed w3m"


    #
    # Bootstrap msys64 into psimacs dir: install git
    #
    #& $bash_exe --login -c "pacman --sync --noconfirm --needed git"
    #& $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-tools-git"
    #& $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-perl-doc"

    #
    # Bootstrap msys64 into psimacs dir: install emacs
    #
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-emacs"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-giflib"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-libjpeg-turbo"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-libpng"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-librsvg"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-libtiff"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-libxml2"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-emacs-pdf-tools-server"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-imagemagick"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-imagemagick-docs"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-zeromq"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-winpty"

    #
    # Bootstrap msys64 into psimacs dir: install tools
    #
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ghostscript"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-graphviz"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-graphviz-docs"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-openexr"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-librsvg"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-libtiff"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-giflib"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-icu"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-cairo"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ca-certificates"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-cmake"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-cmake-docs"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-doxygen"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-grep"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-hugo"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-hunspell"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-hyphen"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-hyphen-en"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-clang-analyzer"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-clang-tools-extra"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-7zip"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-antlr4-runtime-cpp"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-asciidoc"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-asciidoctor"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-aspell-de"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-aspell-en"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-astyle"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-iconv"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ripgrep"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-scite"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-scite-defaults"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-fd"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ffmpeg"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-bat"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-dust"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-eza"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-fzf"
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-meld3"

    #
    # Node.js and mermaid diagramm support
    #
    if (! $no_npm)
    {
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-nodejs"
        & $bash_exe --login -c "npm install -g @mermaid-js/mermaid-cli"
    }
    
    #
    # Bootstrap msys64 into psimacs dir: install nerd fonts
    #
    if ($all_nerd_fonts)
    {
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-nerd-fonts"
    }
    else
    {
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ttf-firacode-nerd"
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ttf-hack-nerd"
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ttf-inconsolata-nerd"
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ttf-sourcecodepro-nerd"
        & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-ttf-0xproto-nerd"
    }

    #
    # Bootstrap msys64 into psimacs dir: install texlive
    #
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-texlive-full"

    #
    # Bootstrap msys64 into psimacs dir: install development
    #
    & $bash_exe --login -c "pacman --sync --noconfirm --needed ${package_prefix}-toolchain"
}

#
# Create a shortcut for the MSYS2 Shell
#
$Shell   = New-Object -comObject WScript.Shell
$Target  = "$msys64\msys2_shell.cmd"
$Icon    = "$msys64\$msys_env_icon"
$Args    = "-${msys_env_arg} -use-full-path"
$Dest    = $Shell.SpecialFolders("Desktop")
$Dest    = "$Dest\Psimacs MSYS2 ${msys_env_name} 64-bit.lnk"

if (! (Test-Path "$Dest" -PathType Leaf) )
{
    echo "Creating MSYS2 ${msys_env_name} 64-bit Dektop Shortcut..."

    $Shortcut = $Shell.CreateShortcut($Dest)
    $Shortcut.WindowStyle      = 1
    $Shortcut.IconLocation     = $Icon
    $Shortcut.TargetPath       = $Target
    $Shortcut.Arguments        = $Args
    $Shortcut.WorkingDirectory = $msys64
    $ShortCut.Description      = "MSYS2 Terminal Shell for Psimacs on ${msys_env_name} 64-bit"
    $Shortcut.Save()
}

#
# Handle reveal.js installation
#
if (-not $no_reveal_js)
{
    $reveal_js_git = "$psimacs\reveal.js\.git"

    if (! (Test-Path $reveal_js_git) )
    {
        echo "Cloning reveal.js..."

        $reveal_js_url = "https://github.com/hakimel/reveal.js.git"

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone $reveal_js_url reveal.js"
    }
}

#
# Handle ConEmu on request
#
if ($conemu)
{
    echo "Installing ConEmu..."

    $conemu_dir = "$psimacs\ConEmu"
    $conemu_7z  = "conemu.7z"

    if ( ! (Test-Path "$conemu_dir") )
    {
        try
        {
            $ProgressPreference = "silentlyContinue"

            $githubLatestReleases = 'https://api.github.com/repos/Maximus5/ConEmu/releases/latest'

            echo "$githubLatestReleases"

            $githubLatestRelease = (((Invoke-WebRequest -Uri $gitHubLatestReleases -UseBasicParsing) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern '.7z').Line

            echo "$githubLatestRelease"

            Invoke-WebRequest -Uri $githubLatestRelease -UseBasicParsing -OutFile "$conemu_7z"
            $ProgressPreference = 'Continue'
        }
        catch
        {
            echo "Downloading of ConEmu installer failed. Prematurely leaving script!"
            Set-Location -Path "$PSScriptRoot"
            return 
        }
    }

    #
    # Extract the ConEmu console
    #
    if ( Test-Path "$psimacs\$conemu_7z" -PathType Leaf )
    {
        echo "Extracting ConEmu archive "$psimacs\$conemu_7z" ..."

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x -oConEmu conemu.7z"

        Remove-Item "$psimacs\$conemu_7z"
    }

    $conemu_cmd = "$conemu_dir\msys2ConEmu.cmd"

    if (! (Test-Path "$conemu_cmd" -PathType Leaf) )
    {
        echo "Writing command script $conemu_cmd ..."

        "@echo off"                                   | out-file -filepath $conemu_cmd -encoding ascii -width 200 
        ""                                            | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        "set `"PATH=$msys64_bin;%PATH%`""             | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        "set CHERE_INVOKING=1"                        | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        "set MSYSTEM=${msys_env_name}64"              | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        "set MSYS2_PATH_TYPE=inherit"                 | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        ""                                            | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        "set `"CONTITLE=MinGW ${msys_env_name} x64`"" | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        ""                                            | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
        "start `"%CONTITLE%`" $conemu_dir\ConEmu64.exe /Here /Icon `"$msys64\$msys_env_icon`" /cmd  `"$bash_exe`" --login -i" | out-file -filepath $conemu_cmd -encoding ascii -width 200 -append
    }

    $Shell   = New-Object -comObject WScript.Shell
    $Target  = "$conemu_cmd"
    $Icon    = "$msys64\$msys_env_icon"
    $Dest    = $Shell.SpecialFolders("Desktop")
    $Dest    = "$Dest\Psimacs ConEmu MSYS2 ${msys_env_name} 64-bit.lnk"

    if (! (Test-Path "$Dest" -PathType Leaf) )
    {
        echo "Creating MSYS2 ConEmu ${msys_env_name} 64-bit Dektop Shortcut..."

        $Shortcut = $Shell.CreateShortcut($Dest)
        $Shortcut.WindowStyle      = 1
        $Shortcut.IconLocation     = $Icon
        $Shortcut.TargetPath       = $Target
        $Shortcut.WorkingDirectory = $env:HOME
        $ShortCut.Description      = "MSYS2 ConEmu Shell for Psimacs on ${msys_env_name} 64-bit"
        $Shortcut.Save()
    }
}

#
# Install Python if requested
#
if (-not $no_python)
{
    if ( (-not $no_python_update) -or (-not (test-path -PathType container $psimacs\$python_dir)) )
    {
        echo "Installing Python $python_version ..."

        if ($python_msi)
        {
            $python_installer = "python-${python_version}-amd64.exe"

            #
            # Download installer
            #
            if ( ! (Test-Path "$psimacs\$python_installer" -PathType Leaf) )
            {
                echo "Downloading $python_installer installer..."

                try
                {
                    $python_installer_url = "https://www.python.org/ftp/python/$python_version/$python_installer"
                    
                    $ProgressPreference = "silentlyContinue"
                    Invoke-WebRequest -Uri $python_installer_url -UseBasicParsing -OutFile $python_installer
                    $ProgressPreference = 'Continue'

                }
                catch
                {
                    echo "Downloading of Python $python_version failed. Check for another Python version. Prematurely leaving script!"
                    Set-Location -Path "$PSScriptRoot"
                    return 
                }
            }

            #
            # Execute the python installer
            #
            if ( Test-Path "$psimacs\$python_installer" -PathType Leaf )
            {
                echo "Running $python_installer installer..."

                Start-Process "$psimacs\$python_installer" -NoNewWindow -Wait -ArgumentList /quiet,Shortcuts=0,Include_launcher=0,AssociateFiles=0,InstallAllUsers=0,TargetDir="$psimacs\$python_dir",DefaultJustForMeTargetDir="$psimacs\$python_dir"
                Remove-Item "$psimacs\$python_installer"
            }
        }
        else
        {
            $python_tar_gz = "python.tar.gz"

            #
            # Download installer
            #
            if ( ! (Test-Path "$psimacs\$python_tar_gz" -PathType Leaf) )
            {
                echo "Downloading $python_url archive..."

                try
                {
                    $ProgressPreference = "silentlyContinue"
                    Invoke-WebRequest -Uri $python_url -UseBasicParsing -OutFile $python_tar_gz
                    $ProgressPreference = 'Continue'
                }
                catch
                {
                    echo "Downloading of Python $python_version from $python_url failed. Check for another PYTHON version. Prematurely leaving script!"
                    Set-Location -Path "$PSScriptRoot"
                    return 
                }
            }

            #
            # Extract the Python archive
            #
            if ( Test-Path "$psimacs\$python_tar_gz" -PathType Leaf )
            {
                echo "Extracting $python_tar_gz archive..."
                & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x $python_tar_gz -so | 7z x -aoa -si -ttar -o.; mv python $python_dir"

                Remove-Item "$psimacs\$python_tar_gz"
            }
        }
    }

    #
    # Create a standard virtual environment from the basic Python installation
    #
    $python_venv_dir = "$psimacs\${python_dir}_0"
    $python_venv_dir_unix = $python_venv_dir.Replace('\', '/')

    if ( ! (test-path -PathType container $python_venv_dir) )
    {
        $python_exe = "$psimacs\$python_dir\python.exe"

        & $python_exe -m venv $python_venv_dir/venv
    }

    #
    # Write helper scripts
    #
    
    $activate_0_ps1 = "$python_venv_dir/activate-0.ps1"
    if (! (Test-Path "$activate_0_ps1" -PathType Leaf) )
    {
        echo "Writing helper script $activate_0_ps1 ..."

        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 
        'function Invoke-CmdScript {'                             | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '    param('                                              | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '        [String] $scriptName'                            | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '    )'                                                   | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '    $cmdLine = """$scriptName"" $args & set"'            | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '    & $Env:SystemRoot\system32\cmd.exe /c $cmdLine |'    | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        "      Select-String '^([^=]*)=(.*)$' |"                  | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '      ForEach-Object {'                                  | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '          $varName  = $_.Matches[0].Groups[1].Value'     | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '          $varValue = $_.Matches[0].Groups[2].Value'     | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '          Set-Item Env:$varName $varValue'               | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '       }'                                                | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '}'                                                       | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$projectPath='+"$python_venv_dir"                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$workPath=$projectPath\work'                             | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$env:MSYS2_ENV='+"$msys_env_arg"                         | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$env:EMACS_PYTHON=$projectPath\venv'                     | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$env:VIRTUAL_ENV=$projectPath\venv'                      | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$env:PYTHONHOME=""'                                      | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '$env:PYDEVD_DISABLE_FILE_VALIDATION = 1'                 | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        'if ( ! (test-path -PathType container $workPath) )'      | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '{'                                                       | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '    New-Item -ItemType Directory -Path $workPath'        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        '}'                                                       | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        'Set-Location -Path "$workPath"'                          | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append
        'Invoke-CmdScript $projectPath\venv\Scripts\activate.bat' | out-file -filepath $activate_0_ps1 -encoding ascii -width 200 -append

        Copy-Item $activate_0_ps1 -Destination $env:HOME
    }

    $activate_0_bash = "$python_venv_dir/activate-0.bash"
    if (! (Test-Path "$activate_0_bash" -PathType Leaf) )
    {
        echo "Writing helper script $activate_0_bash ..."

        "export projectPath=$python_venv_dir_unix"                | out-file -filepath $activate_0_bash -encoding ascii -width 200 
        'export workPath=$projectPath/work'                       | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'source $projectPath/venv/Scripts/activate'               | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'if [[ "$VIRTUAL_ENV_PROMPT" != "" ]]; then'              | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        '    PS1="${VIRTUAL_ENV_PROMPT}${PS1:-}"'                 | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'fi'                                                      | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'PATH="$(cygpath -u $PATH)"'                              | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'export PATH'                                             | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        "export MSYS2_ENV=$msys_env_arg"                          | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'export EMACS_PYTHON=$projectPath/venv'                   | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'export VIRTUAL_ENV=$projectPath/venv'                    | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'export PYTHONHOME='                                      | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'export PYDEVD_DISABLE_FILE_VALIDATION=1'                 | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'if [ ! -d $workPath ]'                                   | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'then'                                                    | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        '    mkdir -p $workPath'                                  | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'fi'                                                      | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append
        'cd $workPath'                                            | out-file -filepath $activate_0_bash -encoding ascii -width 200 -append

        Copy-Item $activate_0_bash -Destination $env:HOME
    }

    $activate_0_bat = "$python_venv_dir/activate-0.bat"
    if (! (Test-Path "$activate_0_bat" -PathType Leaf) )
    {
        echo "Writing helper script $activate_0_bat ..."

        '@echo off'                                               | out-file -filepath $activate_0_bat -encoding ascii -width 200 
        ''                                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        "set projectPath=$python_venv_dir"                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'set workPath=%projectPath%\work'                         | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        "set MSYS2_ENV=$msys_env_arg"                             | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'set EMACS_PYTHON=%projectPath%\venv'                     | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'set VIRTUAL_ENV=%projectPath%\venv'                      | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'set PYTHONHOME='                                         | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'set PYDEVD_DISABLE_FILE_VALIDATION=1'                    | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'mkdir %workPath% 2> NUL'                                 | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'cd /D %workPath%'                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append
        'start %projectPath%\venv\Scripts\activate.bat'           | out-file -filepath $activate_0_bat -encoding ascii -width 200 -append

        Copy-Item $activate_0_bat -Destination $env:HOME
    }

    $ipython_0_bash = "$python_venv_dir/ipython-0.bash"
    if (! (Test-Path "$ipython_0_bash" -PathType Leaf) )
    {
        echo "Writing helper script $ipython_0_bash ..."

        "export projectPath=$python_venv_dir_unix"                | out-file -filepath $ipython_0_bash -encoding ascii -width 200 
        'export workPath=$projectPath/work'                       | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'source $projectPath/venv/Scripts/activate'               | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'if [[ "$VIRTUAL_ENV_PROMPT" != "" ]]; then'              | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        '    PS1="${VIRTUAL_ENV_PROMPT}${PS1:-}"'                 | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'fi'                                                      | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'PATH="$(cygpath -u $PATH)"'                              | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'export PATH'                                             | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        "export MSYS2_ENV=$msys_env_arg"                          | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'export EMACS_PYTHON=$projectPath/venv'                   | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'export VIRTUAL_ENV=$projectPath/venv'                    | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'export PYTHONHOME='                                      | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'export PYDEVD_DISABLE_FILE_VALIDATION=1'                 | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'if [ ! -d $workPath ]'                                   | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'then'                                                    | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        '    mkdir -p $workPath'                                  | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'fi'                                                      | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'cd $workPath'                                            | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        ''                                                        | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append
        'winpty ipython'                                          | out-file -filepath $ipython_0_bash -encoding ascii -width 200 -append

        Copy-Item $ipython_0_bash -Destination $env:HOME
    }
    
    $psimacs_0_cmd  = "$python_venv_dir/psimacs-0.cmd"
    if (! (Test-Path "$psimacs_0_cmd" -PathType Leaf) )
    {
        echo "Writing helper script $psimacs_0_cmd ..."

        '@echo off'                                                   | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 
        ''                                                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        "set projectPath=$python_venv_dir"                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'set workPath=%projectPath%\work'                             | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        ''                                                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'set PYDEVD_DISABLE_FILE_VALIDATION=1'                        | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        ''                                                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'mkdir %workPath% 2> NUL'                                     | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        ''                                                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        "set MSYS2_ENV=$msys_env_arg"                                 | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'set EMACS_PYTHON=%projectPath%\venv'                         | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'set VIRTUAL_ENV=%projectPath%\venv'                          | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'set PYTHONHOME='                                             | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        ''                                                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'net use LPT3: "\\127.0.0.1\EPSON ET-4750 Series"'            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        ''                                                            | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        'cd %workPath%'                                               | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append
        "$msys_env_bin\runemacs.exe -init-directory $psimacs\psimacs" | out-file -filepath $psimacs_0_cmd -encoding ascii -width 200 -append

        Copy-Item $psimacs_0_cmd -Destination $env:HOME
    }

    $psimacs_0_dbg_cmd  = "$python_venv_dir/psimacs-0-dbg.cmd"
    if (! (Test-Path "$psimacs_0_dbg_cmd" -PathType Leaf) )
    {
        echo "Writing helper script $psimacs_0_dbg_cmd ..."

        '@echo off'                                                                | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 
        ''                                                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        "set projectPath=$python_venv_dir"                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'set workPath=%projectPath%\work'                                          | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        ''                                                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'set PYDEVD_DISABLE_FILE_VALIDATION=1'                                     | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        ''                                                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'mkdir %workPath% 2> NUL'                                                  | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        ''                                                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        "set MSYS2_ENV=$msys_env_arg"                                              | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'set EMACS_PYTHON=%projectPath%\venv'                                      | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'set VIRTUAL_ENV=%projectPath%\venv'                                       | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'set PYTHONHOME='                                                          | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        ''                                                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'net use LPT3: "\\127.0.0.1\EPSON ET-4750 Series"'                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        ''                                                                         | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        'cd %workPath%'                                                            | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append
        "$msys_env_bin\runemacs.exe -init-directory $psimacs\psimacs --debug-init" | out-file -filepath $psimacs_0_dbg_cmd -encoding ascii -width 200 -append

        Copy-Item $psimacs_0_dbg_cmd -Destination $env:HOME
    }

    #
    # Update the Python Package Manager pip in the virtual Python environment
    #
    if ( Test-Path "$activate_0_bash" -PathType Leaf )
    {
        echo "Updating Python Package Manager PIP..."

        & $bash_exe --login -c ". $(cygpath --mixed $activate_0_bash); python -m pip install pip --upgrade"
    }
}

if (-not $no_java)
{
    $java_dir = "$psimacs\java64"

    if (-not (test-path -PathType container $java_dir) )
    {
        echo "Installing Java ..."

        $java_zip = "java64.zip"

        #
        # Download installer
        #
        if ( ! (Test-Path "$psimacs\$java_zip" -PathType Leaf) )
        {
            echo "Downloading $java_url archive..."

            try
            {
                $ProgressPreference = "silentlyContinue"
                Invoke-WebRequest -Uri $java_url -UseBasicParsing -OutFile $java_zip
                $ProgressPreference = 'Continue'

            }
            catch
            {
                echo "Downloading of Java $java_version from $java_url failed. Check for another JAVA version. Prematurely leaving script!"
                Set-Location -Path "$PSScriptRoot"
                return 
            }
        }

        #
        # Extract the Java archive
        #
        if ( Test-Path "$psimacs\$java_zip" -PathType Leaf )
        {
            echo "Extracting $java_zip archive..."

            & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x -ojava64 $java_zip"

            Remove-Item "$psimacs\$java_zip"

            Move-Item -Path "$java_dir\$java_jdk\*" -Destination $java_dir
            Remove-Item "$java_dir\$java_jdk"
        }
    }
}

if (-not $no_langtool)
{
    $langtool_dir = "$psimacs\LanguageTool"

    if (-not (test-path -PathType container $langtool_dir) )
    {
        echo "Installing LanguageTool ..."

        $langtool_zip = "LanguageTool-stable.zip"

        #
        # Download installer
        #
        if ( ! (Test-Path "$psimacs\$langtool_zip" -PathType Leaf) )
        {
            $langtool_url = "https://languagetool.org/download/LanguageTool-stable.zip"

            echo "Downloading $langtool_url archive..."

            try
            {
                $ProgressPreference = "silentlyContinue"
                Invoke-WebRequest -Uri $langtool_url -UseBasicParsing -OutFile $langtool_zip
                $ProgressPreference = 'Continue'
            }
            catch
            {
                echo "Downloading of LanguageToolfrom $langtool_url failed! Skipping installation."
            }
        }

        #
        # Execute the python installer
        #
        if ( Test-Path "$psimacs\$langtool_zip" -PathType Leaf )
        {
            echo "Extracting $langtool_zip archive..."

            & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x -oLanguageTool $langtool_zip"

            Remove-Item "$psimacs\$langtool_zip"

            Move-Item -Path "$langtool_dir\*\*" -Destination $langtool_dir

            $dirs = Get-ChildItem "$langtool_dir\LanguageTool-*" -Directory

            foreach ($dir in $dirs)
            {
                try
                {
                    Remove-Item "$dir"
                }
                catch
                {
                    echo "Could not remove directory $dir"
                }
            }
        }
    }
}

if (-not $no_sumatrapdf)
{
    echo "Installing SumatraPDF $sumatrapdf_version ..."

    $sumatrapdf_dir = "SumatraPDF"

    if (test-path -PathType container $psimacs\$sumatrapdf_dir) 
    {
        echo "Removing $psimacs\$sumatrapdf_dir directory..."
        Remove-Item -Path $psimacs\$sumatrapdf_dir -Recurse
    }

    if (-not (test-path -PathType container $psimacs\$sumatrapdf_dir)) 
    {
        $sumatrapdf_zip = "SumatraPDF-${sumatrapdf}-64.zip"

        #
        # Download installer
        #
        if ( ! (Test-Path "$psimacs\$sumatrapdf_zip" -PathType Leaf) )
        {
            echo "Downloading $sumatrapdf_zip installer..."

            try
            {
                $sumatrapdf_zip_url = "https://www.sumatrapdfreader.org/dl/rel/${sumatrapdf_version}/$sumatrapdf_zip"
                
                $ProgressPreference = "silentlyContinue"
                Invoke-WebRequest -Uri $sumatrapdf_zip_url -UseBasicParsing -OutFile $sumatrapdf_zip
                $ProgressPreference = 'Continue'

            }
            catch
            {
                echo "Downloading of SumatraPDF $sumatrapdf_version failed. Check for another SumatraPDF version. Prematurely leaving script!"
                Set-Location -Path "$PSScriptRoot"
                return 
            }
        }

        #
        # Extract the SumatraPDF archive
        #
        if ( Test-Path "$psimacs\$sumatrapdf_zip" -PathType Leaf )
        {
            echo "Extracting $sumatrapdf_zip archive..."

            & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x -o$sumatrapdf_dir $sumatrapdf_zip"

            Remove-Item "$psimacs\$sumatrapdf_zip"
        }

        #
        # Rename the SumatraPDF executable so that Psimacs does not need to know about the version number.
        #
        $sumatrapdf_exe = "$psimacs\${sumatrapdf_dir}\SumatraPDF-${sumatrapdf_version}-64.exe"

        if ( Test-Path "$sumatrapdf_exe" -PathType Leaf )
        {
            echo "Renaming $sumatrapdf_exe executable..."
            Rename-Item -Path "$sumatrapdf_exe" -NewName "SumatraPDF.exe"
        }
    }
}

#
# Install pandoc
#
if (-not $no_pandoc)
{
    echo "Installing pandoc..."

    $pandoc_dir = "$psimacs\pandoc"
    $pandoc_zip  = "pandoc.zip"

    if (test-path -PathType container $pandoc_dir) 
    {
        echo "Removing $pandoc_dir directory..."
        Remove-Item -Path $pandoc_dir -Recurse
    }

    if ( ! (Test-Path "$pandoc_dir") )
    {
        try
        {
            $ProgressPreference = "silentlyContinue"

            $githubLatestReleases = 'https://api.github.com/repos/jgm/pandoc/releases/latest'
            $githubLatestRelease = (((Invoke-WebRequest -Uri $gitHubLatestReleases -UseBasicParsing) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern '-windows-x86_64.zip').Line

            Invoke-WebRequest -Uri $githubLatestRelease -UseBasicParsing -OutFile "$pandoc_zip"
            $ProgressPreference = 'Continue'
        }
        catch
        {
            echo "Downloading of pandoc installer failed. Prematurely leaving script!"
            Set-Location -Path "$PSScriptRoot"
            return 
        }
    }

    #
    # Extract the pandoc archive
    #
    if ( Test-Path "$psimacs\$pandoc_zip" -PathType Leaf )
    {
        echo "Extracting pandoc archive "$psimacs\$pandoc_zip" ..."

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x -opandoc $pandoc_zip"

        Remove-Item "$psimacs\$pandoc_zip"

        $dirs = Get-ChildItem "$pandoc_dir\pandoc-*" -Directory

        foreach ($dir in $dirs)
        {
            try
            {
                Move-Item -Path "$dir\*" -Destination $pandoc_dir
                Remove-Item "$dir"
            }
            catch
            {
                echo "Could not remove directory $dir"
            }
        }
    }
}

#
# Clone Psimacs
#
#
# Test for existing psimacs installation: if init.el exists exit
#
$init_el     = "$psimacs\psimacs\init.el"
$psimacs_git = "$psimacs\psimacs\.git"

if (! (Test-Path $init_el -PathType Leaf) )
{
    if (! (Test-Path $psimacs_git) )
    {
        echo "Cloning Psimacs..."

        $psimacs_url = "https://github.com/hatlafax/psimacs.git"

        if ($psimacsbranch)
        {
            & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone -b $psimacsbranch $psimacs_url psimacs"
        }
        else
        {
            & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone $psimacs_url psimacs"
        }
    }


    $else_grammar_compiler_git = "$psimacs\ELSE-grammar-compiler\.git"

    if (! (Test-Path $else_grammar_compiler_git) )
    {
        echo "Cloning ELSE grammar compiler..."

        $else_grammar_compiler_url = "https://github.com/hatlafax/ELSE-grammar-compiler.git"

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone $else_grammar_compiler_url ELSE-grammar-compiler"
    }

    if (! (Test-Path "$psimacs_0_cmd" -PathType Leaf) )
    {
        $psimacs_cmd = "$psimacs\psimacs.cmd"

        if (! (Test-Path "$psimacs_cmd" -PathType Leaf) )
        {
            echo "Writing command script $psimacs_cmd ..."

            '@echo off'                                                   | out-file -filepath $psimacs_cmd -encoding ascii -width 200 
            ''                                                            | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            'set projectPath=%HOME%'                                      | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            'set workPath=%HOME%'                                         | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            ''                                                            | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            "set MSYS2_ENV=$msys_env_arg"                                 | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            ''                                                            | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            'set PYDEVD_DISABLE_FILE_VALIDATION=1'                        | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            ''                                                            | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            'net use LPT3: "\\127.0.0.1\EPSON ET-4750 Series"'            | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            ''                                                            | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            'cd %HOME%'                                                   | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
            "$msys_env_bin\runemacs.exe -init-directory $psimacs\psimacs" | out-file -filepath $psimacs_cmd -encoding ascii -width 200 -append
        }

        $emacs = "$psimacs_cmd"
    }
    else
    {
        $emacs = "$psimacs_0_cmd"
    }
    
    $emacs_ico  = "$psimacs\psimacs\psi.ico"

    $client     = "$msys_env_bin\emacsclientw.exe"
    $client_ico = "$psimacs\psimacs\psi-cli.ico"

    $Shell   = New-Object -comObject WScript.Shell

    $Target  = "$emacs"
    $Icon    = "$emacs_ico"
    $Dest    = $Shell.SpecialFolders("Desktop")
    $Dest    = "$Dest\Psimacs Server.lnk"

    if (! (Test-Path "$Dest" -PathType Leaf) )
    {
        echo "Psimacs Server Shortcut..."

        $Shortcut = $Shell.CreateShortcut($Dest)
        $Shortcut.WindowStyle      = 1
        $Shortcut.IconLocation     = $Icon
        $Shortcut.TargetPath       = $Target
        $Shortcut.WorkingDirectory = $env:HOME
        $ShortCut.Description      = "Psimacs Server"
        $Shortcut.Save()
    }

    $Target  = "$client"
    $Icon    = "$client_ico"
    #$Args    = "-n -a `"$emacs -init-directory $psimacs/psimacs`""
    $Args    = "-n -a $emacs -c"
    $Dest    = $Shell.SpecialFolders("Desktop")
    $Dest    = "$Dest\Psimacs Client.lnk"

    if (! (Test-Path "$Dest" -PathType Leaf) )
    {
        echo "Psimacs Client Shortcut..."

        $Shortcut = $Shell.CreateShortcut($Dest)
        $Shortcut.WindowStyle      = 1
        $Shortcut.IconLocation     = $Icon
        $Shortcut.TargetPath       = $Target
        $Shortcut.Arguments        = $Args
        $Shortcut.WorkingDirectory = $env:HOME
        $ShortCut.Description      = "Psimacs Client"
        $Shortcut.Save()
    }

    if (-not $no_psimacsdocu)
    {
        $Icon    = "$emacs_ico"
        $Desk    = $Shell.SpecialFolders("Desktop")

        $Target  = "$psimacs\psimacs\docs\init.html"
        $Dest    = "$Desk\Psimacs Documentation.lnk"
        $Desc    = "Psimacs Documentation"

        if (! (Test-Path "$Dest" -PathType Leaf) )
        {
            echo "Psimacs Documentation Shortcut..."

            $Shortcut = $Shell.CreateShortcut($Dest)
            $Shortcut.WindowStyle      = 1
            $Shortcut.IconLocation     = $Icon
            $Shortcut.TargetPath       = $Target
            $Shortcut.WorkingDirectory = $env:HOME
            $ShortCut.Description      = $Desc
            $Shortcut.Save()
        }

        $Target  = "$psimacs\psimacs\docs\keybindings.html"
        $Dest    = "$Desk\Psimacs Key Bindings.lnk"
        $Desc    = "Psimacs Key Bindings"

        if (! (Test-Path "$Dest" -PathType Leaf) )
        {
            echo "Psimacs Documentation Shortcut..."

            $Shortcut = $Shell.CreateShortcut($Dest)
            $Shortcut.WindowStyle      = 1
            $Shortcut.IconLocation     = $Icon
            $Shortcut.TargetPath       = $Target
            $Shortcut.WorkingDirectory = $env:HOME
            $ShortCut.Description      = $Desc
            $Shortcut.Save()
        }
    }
}

if (-not $no_python)
{
    if (-not $no_python_packages)
    {
        #
        # Install the Python Requirements
        #
        if ( ($python_requirements) -and (Test-Path "$python_requirements"))
        {
            echo "...using $python_requirements"
            $psimacs_py_requirements = "$python_requirements".Replace('\', '/')
        }
        else
        {
            echo "...using requirements from assets directory"
            $psimacs_py_requirements = "$psimacs\psimacs\assets\dependencies\windows\python\requirements.txt".Replace('\', '/')
        }

        if ( Test-Path "$activate_0_bash" -PathType Leaf )
        {
            echo "Installing the Python packages as defined in file $psimacs_py_requirements ..."
            & $bash_exe --login -c ". $(cygpath --mixed $activate_0_bash); pip install -r $psimacs_py_requirements"
        }
    }
}

#
# Handle PlantHML on request
#
if (-not $no_plantuml)
{
    echo "Installing PlantUML..."

    $plantuml_dir = "$psimacs\plantUML"
    $plantuml_jar = "$plantuml_dir\plantuml.jar"
    $plantuml_pdf  = "$plantuml_dir\plantuml.pdf"

    if ( ! (Test-Path "$plantuml_dir") )
    {
        try
        {
            $ProgressPreference = "silentlyContinue"

            $githubLatestReleases = 'https://api.github.com/repos/plantuml/plantuml/releases/latest'
            $githubLatestRelease = (((Invoke-WebRequest -Uri $gitHubLatestReleases -UseBasicParsing) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern '^.*plantuml-\d\.\d+\.\d+\.jar$').Line

            New-Item -ItemType Directory -Path $plantuml_dir

            Invoke-WebRequest -Uri $githubLatestRelease -UseBasicParsing -OutFile "$plantuml_jar"


            $plantuml_pdf_url = "https://plantuml.com/de/guide"
            Invoke-WebRequest -Uri $plantuml_pdf_url -UseBasicParsing -OutFile "$plantuml_pdf"

            $ProgressPreference = 'Continue'
        }
        catch
        {
            echo "Downloading of plantUML failed. Prematurely leaving script!"
            Set-Location -Path "$PSScriptRoot"
            return 
        }
    }
}

if (-not $no_privatefile)
{
    $private_dir  = "$psimacs/psimacs/private"
    $private_file = "$private_dir/init-private.el"

    if ( ! (Test-Path "$private_dir") )
    {
        echo "Creating Psimacs private directory ..."

        New-Item -ItemType Directory -Path $private_dir
    }

    if (! (Test-Path "$private_file" -PathType Leaf) )
    {
        echo "Writing Psimacs $private_file file ..."

       ';;; init-personal.el --- Personal setup -*- lexical-binding: t -*-'   | out-file -filepath $private_file -encoding ascii -width 200 
       ''                                                                     | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; Copyright (C) 2020-2021 Johannes Brunen (hatlafax)'                | out-file -filepath $private_file -encoding ascii -width 200 -append
       ''                                                                     | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; Author:  Johannes Brunen <hatlafax@gmx.de>'                        | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; URL:     https://github.com/hatlafax/psimacs'                      | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; License: GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007'       | out-file -filepath $private_file -encoding ascii -width 200 -append
       ''                                                                     | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; This file is not part of GNU Emacs.'                               | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';;'                                                                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; This program is free software; you can redistribute it and/or'     | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; modify it under the terms of the GNU GENERAL PUBLIC LICENSE'       | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; Version 3, 29 June 2007 published by the Free Software Foundation.'| out-file -filepath $private_file -encoding ascii -width 200 -append
       ';;'                                                                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; This program is distributed in the hope that it will be useful,'   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; but WITHOUT ANY WARRANTY; without even the implied warranty of'    | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU' | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; General Public License for more details.'                          | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';;'                                                                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; You should have received a copy of the GNU General Public License' | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; along with this program; see the file LICENSE.  If not, write to'  | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; the Free Software Foundation, Inc., 51 Franklin Street, Fifth'     | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; Floor, Boston, MA 02110-1301, USA.'                                | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';;'                                                                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ''                                                                     | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';;'                                                                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';; Private information that should not go to github'                  | out-file -filepath $private_file -encoding ascii -width 200 -append
       ';;'                                                                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       "(setq user-full-name         `"$username`""                           | out-file -filepath $private_file -encoding ascii -width 200 -append
       "      user-mail-address      `"$useremail`""                          | out-file -filepath $private_file -encoding ascii -width 200 -append
       "      calendar-latitude      $calendarlatitude"                       | out-file -filepath $private_file -encoding ascii -width 200 -append
       "      calendar-longitude     $calendarlongitude"                      | out-file -filepath $private_file -encoding ascii -width 200 -append
       "      calendar-location-name `"$calendarlocation`""                   | out-file -filepath $private_file -encoding ascii -width 200 -append
       ')'                                                                    | out-file -filepath $private_file -encoding ascii -width 200 -append
       ''                                                                     | out-file -filepath $private_file -encoding ascii -width 200 -append
       "(provide 'init-private)"                                              | out-file -filepath $private_file -encoding ascii -width 200 -append
       ''                                                                     | out-file -filepath $private_file -encoding ascii -width 200 -append
    }
}

if ($no_package_versions)
{
    $straight_dir = "$psimacs/psimacs/straight"
    $straight_versions_file = "$straight_dir/versions/default.el"

    if ( Test-Path "$straight_versions_file" -PathType Leaf )
    {
        echo "Removing Psimacs packages version file $straight_versions_file ..."
        Remove-Item -Force "$straight_versions_file"
    }
}

if (-not $no_fonts_install)
{
    function Install-Font {
        param
        (
            [Parameter(Mandatory)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$FontFile,
            [Parameter(Mandatory)][Boolean]$InstallSystemWide
        )
        
        #Get Font Name from the File's Extended Attributes
        $oShell = new-object -com shell.application
        $Folder = $oShell.namespace($FontFile.DirectoryName)
        $Item = $Folder.Items().Item($FontFile.Name)
        $FontName = $Folder.GetDetailsOf($Item, 21)
        try {
            switch ($FontFile.Extension) {
                ".ttf" {$FontName = $FontName + [char]32 + '(TrueType)'}
                ".otf" {$FontName = $FontName + [char]32 + '(OpenType)'}
            }
            if ($InstallSystemWide) {
                    $fontTarget = $env:windir + "\Fonts\" + $FontFile.Name
                    $regPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
                    $regValue = $FontFile.Name
                    $regName = $FontName
            } else {
                    # Check whether Windows Version is high enough to support per-user font installation without admin rights
                    $winMajorVersion = [Environment]::OSVersion.Version.Major
                    $winBuild = [Environment]::OSVersion.Version.Build
                    If ( -not (($winMajorVersion -ge 10) -and ($winBuild -ge 17044))) {
                        throw "At least Windows 10 Build 17044 is required for local user installation. You have Win $winMajorVersion Build $winBuild."
                    }
                    $fontTarget = $env:localappdata + "\Microsoft\Windows\Fonts\" 
                    $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
                    $regValue = $fontTarget + $FontFile.Name
                    $regName = $FontName
                    # The Fonts directory does not always exist on a per user level. Create it.
                    New-Item -ItemType Directory -Force -Path "$fontTarget"
            }

            $CopyFailed = $true
            Write-Host ("Copying $($FontFile.Name).....") -NoNewline
            Copy-Item -Path $fontFile.FullName -Destination ($fontTarget) -Force
            # Test if font is copied over
            If ((Test-Path ($fontTarget)) -eq $true) {
                Write-Host ('Success') -Foreground Yellow
            } else {
                Write-Host ('Failed to copy file') -ForegroundColor Red
            }
            $CopyFailed = $false

            # Create Registry item for font
            Write-Host ("Adding $FontName to the registry.....") -NoNewline
            If (!(Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType string -Force -ErrorAction SilentlyContinue| Out-Null

            $AddKeyFailed = $true
            If ((Get-ItemPropertyValue -Name $regName -Path $regPath) -eq $regValue) {
                Write-Host ('Success') -ForegroundColor Yellow
            } else {
                Write-Host ('Failed to set registry key') -ForegroundColor Red
            }
            $AddKeyFailed = $false
            
        } catch {
            If ($CopyFailed -eq $true) {
                Write-Host ('Font file copy Failed') -ForegroundColor Red
                $CopyFailed = $false
            }
            If ($AddKeyFailed -eq $true) {
                Write-Host ('Registry Key Creation Failed') -ForegroundColor Red
                $AddKeyFailed = $false
            }
            write-warning $_.exception.message
        }
        Write-Host
    }

    $dirs = @()

    $dirs += "$msys_env_share\fonts\OTF"
    $dirs += "$msys_env_share\fonts\TTF"

    $all_the_icons_dir  = "temp-all-the-icons"
    $all_the_icons_path = "$psimacs\$all_the_icons_dir"

    if (-not $no_all_the_icons)
    {
        echo "Cloning temporary all-the-icons repository ..."

        $all_the_icons_url = "https://github.com/domtronn/all-the-icons.el.git"

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone $all_the_icons_url $all_the_icons_dir"

        $dirs += "$all_the_icons_path/fonts"
    }

    $nerd_icons_dir  = "temp-nerd-icons"
    $nerd_icons_path = "$psimacs\$nerd_icons_dir"

    if (-not $no_nerd_icons)
    {
        echo "Cloning temporary nerd-icons repository ..."

        $nerd_icons_url = "https://github.com/rainstormstudio/nerd-icons.el.git"

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone $nerd_icons_url $nerd_icons_dir"

        $dirs += "$nerd_icons_path/fonts"
    }

    foreach ($dir in $dirs)
    {
        if ( test-path -PathType container $dir )
        {
            foreach ($FontItem in (Get-ChildItem -Path $dir | Where-Object {
                    ($_.Name -like '*.ttf') -or ($_.Name -like '*.OTF')
                }))
            {
                Install-Font -FontFile $FontItem $isAdmin
            }
        }
    }

    if ( test-path -PathType container $all_the_icons_path )
    {
        echo "Removing temporary all-the-icons repository ..."

        Remove-Item -Recurse -Force "$all_the_icons_path"
    }

    if ( test-path -PathType container $nerd_icons_path )
    {
        echo "Removing temporary nerd-icons repository ..."

        Remove-Item -Recurse -Force "$nerd_icons_path"
    }
}

if (-not $no_org_themes)
{
    $themes_url = "https://gitlab.com/OlMon/org-themes.git"
    $themes_dir = "$psimacs\psimacs\content\themes"

    if ( -not (test-path -PathType container $themes_dir) )
    {
        echo "Cloning ORG themes repository ..."

        New-Item -ItemType Directory -Path $themes_dir

        & $bash_exe --login -c "cd $(cygpath --mixed $themes_dir); git clone $themes_url org-themes"
    }
}

if (-not $no_content)
{
    $content_dir = "$psimacs\psimacs\content"
    
    if ( -not (test-path -PathType container $content_dir) )
    {
        New-Item -ItemType Directory -Path $content_dir
    }
    else
    {
        echo "A content directory $content_dir already exists."
    }

    $content_bib_dir  = "$psimacs\psimacs\content\bibliography"
    $content_bib_file = "$content_bib_dir\bibliography.bib"

    if ( -not (test-path -PathType container $content_bib_dir) )
    {
        echo "Writing Psimacs $content_bib_file file ..."

        New-Item -ItemType Directory -Path $content_bib_dir

       '#+latex \usepackage{textgreek}'   | out-file -filepath $content_bib_file -encoding ascii -width 200 
    }

    $content_private_latex_dir  = "$psimacs\psimacs\content\org\private"
    $content_private_latex_file = "$content_private_latex_dir\PrivateLatexPreamble.org"

    if ( -not (test-path -PathType container $content_private_latex_dir) )
    {
        echo "Writing Psimacs $content_private_latex_file file ..."

        New-Item -ItemType Directory -Path $content_private_latex_dir

        '#+latex_header: \author{YOUR FULL NAME}'                 | out-file -filepath $content_private_latex_file -encoding ascii -width 200 
        '#+latex_header: \authorsaffiliations{YOUR AFFILIATIONS}' | out-file -filepath $content_private_latex_file -encoding ascii -width 200 -append
        '#+latex_header: \leftheader{YOUR NAME}'                  | out-file -filepath $content_private_latex_file -encoding ascii -width 200 -append
    }
}

if (-not $no_whisper)
{
    echo "Installing whisper.cpp..."

    $whisper_cpp_git = "$psimacs\whisper.cpp\.git"

    if (! (Test-Path $whisper_cpp_git) )
    {
        echo "Cloning whisper.cpp..."

        $whisper_cpp_url = "https://github.com/ggml-org/whisper.cpp.git"

        & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); git clone $whisper_cpp_url whisper.cpp"
    }

    $whisper_cpp_build_dir = "$psimacs\whisper.cpp\build"
    $whisper_cpp_build_bin_dir = "$whisper_cpp_build_dir\bin"

    if (Test-Path $whisper_cpp_build_bin_dir) {
        echo "Directory $whisper_cpp_build_bin_dir already exists!"
    } else {
        echo "Creating directory $whisper_cpp_build_bin_dir..."
        New-Item -Path "$whisper_cpp_build_bin_dir" -ItemType Directory -Force
    }

    if (Test-Path $whisper_cpp_build_bin_dir) {
        $whisper_cli_path = "$whisper_cpp_build_bin_dir\whisper-cli.exe"

        if ( Test-Path "$whisper_cli_path" -PathType Leaf ) {
            "Whisper command line driver '$whisper_cli_path' found! Skipping CLI driver installation!"
        } else {
            "Installing Whisper command line driver '$whisper_cli_path'..."

            try
            {
                $ProgressPreference = "silentlyContinue"

                $githubLatestReleases = 'https://api.github.com/repos/ggml-org/whisper.cpp/releases/latest'
                echo "$githubLatestReleases"

                $githubLatestRelease_x64_zip = (((Invoke-WebRequest -Uri $gitHubLatestReleases -UseBasicParsing) | ConvertFrom-Json).assets.browser_download_url | select-string -Pattern '-x64.zip')

                foreach ($whisper_rel in $githubLatestRelease_x64_zip) {
                    $zip_file = Split-Path $whisper_rel -leaf

                    $download = $false

                    if ($all_whisper_releases) {
                        $download = $true
                    } else {
                        if ("$zip_file" -eq "${whisper_release}.zip") {
                            $download = $true
                        }
                    }

                    if ($download) {
                        Start-BitsTransfer -Source $whisper_rel -Destination $zip_file

                        if ( Test-Path "$psimacs\$zip_file" -PathType Leaf )
                        {
                            echo "Extracting $zip_file archive..."

                            & $bash_exe --login -c "cd $(cygpath --mixed $psimacs); 7z x -owhisper_bin $zip_file"

                            if ("$zip_file" -eq "${whisper_release}.zip") {
                                Copy-Item -Path "whisper_bin\Release\*" -Destination $whisper_cpp_build_bin_dir
                            }

                            if ($all_whisper_releases) {
                                $dst_dir = (Get-Item $zip_file ).Basename
                                $dst_dir = "$whisper_cpp_build_dir/bin_$dst_dir"

                                if (Test-Path $dst_dir ) {
                                    echo "Removing directory '$dst_dir'"
                                    Remove-Item -Recurse -Force "$dst_dir"
                                }
                                
                                echo "Creating directory '$dst_dir'..."
                                New-Item -Path "$dst_dir" -ItemType Directory -Force

                                Move-Item -Path "whisper_bin\Release\*" -Destination $dst_dir
                            }
                            Remove-Item -Recurse -Force "whisper_bin"
                            Remove-Item "$psimacs\$zip_file"
                        }                        
                    }
                }

                $ProgressPreference = 'Continue'


            }
            catch
            {
                echo "Downloading of Whisper release failed. Prematurely leaving script!"
                Set-Location -Path "$PSScriptRoot"
                return 
            }
        }
    }
}

if (-not $no_whisper_models)
{
    echo "Installing whisper models from Hugging Face..."

    $whisper_cpp_models_dir = "$psimacs\whisper.cpp\models"

    if (Test-Path $whisper_cpp_models_dir)
    {
        if ($all_whisper_models)
        {
            echo "Installing all whisper models: $whisper_models"
        }
        else
        {
            echo "Installing only the following models: $whisper_models"
        }

        foreach ($model in  $whisper_models) {
            $model_file = "ggml-${model}.bin"
            $model_path = "$whisper_cpp_models_dir\$model_file"

            if ( Test-Path "$model_path" -PathType Leaf ) {
                echo "Model file '$model_file' already exists in folder '$whisper_cpp_models_dir'! Skipping file."
            } else {
                echo "Installing whisper model: $model_file"

                if ($model.EndsWith("tdrz")) {
                    Start-BitsTransfer -Source https://huggingface.co/akashmjn/tinydiarize-whisper.cpp/resolve/main/$model_file -Destination $model_path
                } else {
                    Start-BitsTransfer -Source https://huggingface.co/ggerganov/whisper.cpp/resolve/main/$model_file -Destination $model_path
                }

            }
        }
    }
    else
    {
        echo "Directory $whisper_cpp_models_dir could not be found!"
    }


    
}

#
# Go back to script root directory
#
Set-Location -Path "$PSScriptRoot"

