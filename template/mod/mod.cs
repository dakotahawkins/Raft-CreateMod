//--------------------------------------------------------------------------------------------------
// <copyright file="@ModName-NoSpace@.cs" company="@AuthorName@">
//     Copyright (c) @AuthorName@. All rights reserved.
// </copyright>
// <license>
//     MIT License
//
//     Copyright(c) @Year@ @AuthorName@
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in all
//     copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//     SOFTWARE.
// </license>
//--------------------------------------------------------------------------------------------------
#pragma warning disable 1692 // Invalid number, triggered from the mod loader for the SA* pragmas
#pragma warning disable SA1009 // ClosingParenthesisMustBeSpacedCorrectly
#pragma warning disable SA1111 // ClosingParenthesisMustBeOnLineOfLastParameter
#pragma warning restore 1692
namespace @AuthorName-NoSpace@
{
    using System.Collections.Generic;
    using System.Globalization;
    using System.Linq;

    using UnityEngine;

    /// <summary>
    /// Main mod class.
    /// </summary>
    [ModTitle("@ModName@")]
    [ModDescription(
        "@ModDescription@"
    )]
    [ModAuthor("@AuthorName@")]
    [ModIconUrl(MyCurrentUrlRoot + "icon.jpg")] // 256x256px
    [ModWallpaperUrl(MyCurrentUrlRoot + "banner.jpg")] // 660x200px
    [ModVersionCheckUrl(
        "@ModVersionUrl@"
    )]
    [ModVersion(MyCurrentVersion)]
    [RaftVersion(RaftVersion)]
    [ModIsPermanent(false)]
    public class @ModName-NoSpace@ : Mod
    {
        /// <summary>
        /// Current version of this mod.
        /// </summary>
        private const string MyCurrentVersion = "@VERSION@";

        /// <summary>
        /// URL root for current version of this mod.
        /// </summary>
        private const string MyCurrentUrlRoot =
            "https://raw.githubusercontent.com/"
            + "@GitHubUserName@/"
            + "@GitHubProjectName@/"
            + MyCurrentVersion + "/"
            + "ModResources/";

        /// <summary>
        /// Supported/recommended version of Raft.
        /// </summary>
        private const string RaftVersion = "Update 10.07 4497220";

        /// <summary>
        /// Prefix logs with colored mod name.
        /// </summary>
        private const string MyLogPrefix =
            "[" + "<color=#@ModColor@>@ModName@</color>" + "] ";

        /// <summary>
        /// Enables or disables additional debug logging.
        /// </summary>
        /// <remarks>
        /// Toggle with the console command "@ModName-NoSpace@ ( d | debug )".
        /// </remarks>
        private static bool debugEnabled = false;

        /// <summary>
        /// Runs a command or prints help.
        /// </summary>
        /// <remarks>
        /// Called by the console command "@ModName-NoSpace@".
        /// </remarks>
        public static void RunCommand()
        {
            var command = RConsole.lcargs.Skip(1).FirstOrDefault();
            if (command.IsNullOrEmpty() || new[] { "h", "help" }.Contains(command))
            {
                PrintCommandHelp();
                return;
            }

            if (new[] { "d", "debug" }.Contains(command))
            {
                ToggleDebug();
                return;
            }

            PrintCommandHelp("Unrecognized command.");

            // Future use:
            // var commandArgs = RConsole.lcargs.Skip(2).ToList();
        }

        /// <summary>
        /// Called when mod is loaded.
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage(
            "Performance",
            "CA1822:Mark members as static",
            Justification = "Remove justification and make static if you never access instace data."
        )]
        public void Start()
        {
            // Register "@ModName-NoSpace@" console command
            const string commandUsage =
                "Usage: @ModName-NoSpace@ [command]."
                + " Use the command \"help\" for a list of commands.";
            RConsole.registerCommand(
                typeof(@ModName-NoSpace@),
                commandUsage,
                "@ModName-NoSpace@",
                RunCommand
            );

            Log(LogType.Log, "loaded");
        }

        /// <summary>
        /// Called every frame. Remove if unused.
        /// </summary>
        [System.Diagnostics.CodeAnalysis.SuppressMessage(
            "Performance",
            "CA1822:Mark members as static",
            Justification = "Remove justification and make static if you never access instace data."
        )]
        public void Update()
        {
            // Remove if Update() unused!
        }

        /// <summary>
        /// Called when mod is unloaded.
        /// </summary>
        public void OnModUnload()
        {
            @ModName-NoSpace@.Destroy(this.gameObject); // Please do not remove that line!

            Log(LogType.Log, "unloaded");
        }

        /// <summary>
        /// Writes a formatted log message to the console.
        /// </summary>
        /// <param name="type">Type of log message.</param>
        /// <param name="log">Log message.</param>
        private static void Log(UnityEngine.LogType type, string log)
        {
            RConsole.Log(type, MyLogPrefix + log);
        }

        /// <summary>
        /// Writes a formatted log message to the console if debugging is enabled.
        /// </summary>
        /// <param name="type">Type of log message.</param>
        /// <param name="log">Log message.</param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage(
            "Code Quality",
            "IDE0051:Remove unused private members",
            Justification = "Remove this suppression once your mod calls this function"
        )]
        private static void LogDebug(UnityEngine.LogType type, string log)
        {
            if (!debugEnabled)
            {
                return;
            }

            Log(type, log);
        }

        /// <summary>
        /// Prints the command help to the console.
        /// </summary>
        /// <param name="error">Optional error message.</param>
        /// <remarks>
        /// Called by the console command "@ModName-NoSpace@ ( h | help )".
        /// </remarks>
        private static void PrintCommandHelp(string error = "")
        {
            var helpMessage = new List<string>
            {
                string.Empty,
                "Usage: <b>@ModName-NoSpace@ <i>[command]</i></b>",
                string.Empty,
                "Executes the specified @ModName-NoSpace@ command.",
                string.Empty,
                "Commands:",
                "    <b>h</b>, <b>help</b>:   Displays this message",
                "    <b>d</b>, <b>debug</b>:  Toggles additional debug logging",
                string.Empty,
            };

            if (!error.IsNullOrEmpty())
            {
                helpMessage.InsertRange(
                    0,
                    new List<string>
                    {
                        string.Empty,
                        "Error: " + error,
                    }
                );
            }

            foreach (var helpLine in helpMessage)
            {
                Log(LogType.Log, helpLine);
            }
        }

        /// <summary>
        /// Toggles additional debug logging.
        /// </summary>
        /// <remarks>
        /// Called by the console command "@ModName-NoSpace@ ( d | debug )".
        /// </remarks>
        private static void ToggleDebug()
        {
            debugEnabled = !debugEnabled;
            Log(
                LogType.Log,
                string.Format(
                    CultureInfo.CurrentCulture,
                    "{0} additional debug logging",
                    debugEnabled ? "Enabled" : "Disabled"
                )
            );
        }
    }
} // namespace @AuthorName-NoSpace@
