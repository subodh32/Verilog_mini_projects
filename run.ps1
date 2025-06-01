# This script takes a list of input files and an output file name,
# then runs the iverilog command, followed by the vvp command,
# and finally opens the generated VCD file with gtkwave.

param (
    [Parameter(Mandatory=$true)]
    [string[]]$i, # Input Verilog files

    [Parameter(Mandatory=$true)]
    [string]$o    # Output VCD file name (e.g., "simulation.vcd")
)

Write-Host "--- Icarus Verilog, VVP, and GTKWave Script ---"

# --- Input Validation ---
if ($i.Count -eq 0) {
    Write-Error "No input files provided. Please specify one or more files using -i."
    exit 1
}

if ([string]::IsNullOrEmpty($o)) {
    Write-Error "No output file name provided. Please specify an output file using -o."
    exit 1
}

# --- Step 1: Run iverilog ---
Write-Host "`n--- Running iverilog ---"
$iverilogCommand = "iverilog -o $($o) $($i -join ' ')"
Write-Host "Attempting to execute: $iverilogCommand"

try {
    # Start-Process for iverilog. Use -NoNewWindow and -Wait.
    # Out-Null suppresses any direct console output from iverilog itself.
    Start-Process -FilePath "iverilog" -ArgumentList "-o $($o) $($i -join ' ')" -NoNewWindow -Wait -PassThru 
    Write-Host "iverilog command completed."

    # Verify if the output file was created
    if (Test-Path $o) {
        Write-Host "$o was created successfully by iverilog."
    } else {
        Write-Warning "$o was not found after iverilog execution. iverilog might have failed or produced no output."
        exit 1 # Exit if iverilog failed to produce the output file
    }

} catch {
    Write-Error "An error occurred while running iverilog: $($_.Exception.Message)"
    exit 1
}

# --- Step 2: Run vvp on the generated output file ---
Write-Host "`n--- Running vvp ---"
$vvpCommand = "vvp $($o)"
Write-Host "Attempting to execute: $vvpCommand"

try {
    # Run vvp and suppress its console output by redirecting to Out-Null.
    # -NoNewWindow and -Wait are used here.
    Write-Host "Executing vvp. Any console output from vvp will be suppressed."
    Start-Process -FilePath "vvp" -ArgumentList "$($o)" -NoNewWindow -Wait -PassThru 
    Write-Host "vvp command completed."

} catch {
    Write-Error "An error occurred while running vvp: $($_.Exception.Message)"
    exit 1
}

# --- Step 3: Run gtkwave on the VCD output file ---
Write-Host "`n--- Running gtkwave ---"
$gtkwaveCommand = "gtkwave $($o)"
Write-Host "Attempting to execute: $gtkwaveCommand"

try {
    # Run gtkwave. We do NOT use -NoNewWindow or Out-Null here,
    # as gtkwave is a GUI application that needs to open a window.
    # -Wait is used to ensure the script waits for gtkwave to be closed.
    Write-Host "Opening $o with gtkwave. Please close the gtkwave window when you are done."
    Start-Process -FilePath "gtkwave" -ArgumentList "$($o)" -Wait -PassThru # Out-Null is used here to prevent gtkwave's *own* console output from showing up in the PowerShell window, while still allowing the GUI to launch.
    Write-Host "gtkwave process completed (window was likely closed)."

} catch {
    Write-Error "An error occurred while running gtkwave: $($_.Exception.Message)"
    exit 1
}

Write-Host "`n--- Script Finished Successfully ---"

# Example of how to run this script from PowerShell:
# .\YourScriptFileName.ps1 -i "design.v" "testbench.v" -o "my_simulation.vcd"
# Or if you have a single file:
# .\YourScriptFileName.ps1 -i "single_file.v" -o "test_output.vcd"
