[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
#test

#Mandatory variables

$SCCMServer = "SCCM2012"
$sitename = "P01"

#region begin to draw forms
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Remove SCCM object tool"
$Form.Size = New-Object System.Drawing.Size(400,200)
$Form.StartPosition = "CenterScreen"
$Form.KeyPreview = $True
$Form.MaximumSize = $Form.Size
$Form.MinimumSize = $Form.Size

$label = New-Object System.Windows.Forms.label
$label.Location = New-Object System.Drawing.Size(5,5)
$label.Size = New-Object System.Drawing.Size(240,30)
$label.Text = "Device name:"
$Form.Controls.Add($label)
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Size(5,40)
$textbox.Size = New-Object System.Drawing.Size(120,20)
#$textbox.Text = "Select source PC:"
$Form.Controls.Add($textbox)

$ping_computer_click =
{
#region Actual Code

$statusBar1.Text = "Deleting..."
$ComputerName = $textbox.Text


# Get Resource ID of Computer Name

$resID = Get-WmiObject -computername $SCCMServer -query "select resourceID from sms_r_system where name like `'$Computername`'" -Namespace "root\sms\site_$sitename"

if ($resID.ResourceId -eq $null)

{
Write-Host -ForegroundColor Green "Computer $ComputerName does not exist in SCCM"
$result_label.ForeColor= "Red"
$result_label.Text = "Computer $ComputerName does not exist in SCCM"
}

else

{

    # Get the specified computerobject based on found ID

    $comp = [wmi]"\\$SCCMServer\root\sms\site_$($sitename):sms_r_system.resourceID=$($resID.ResourceId)"

    # Delete it

    $comp.psbase.delete()

    # Successful deletion?

    if($?)
{
$result_label.ForeColor= "Green"
$result_label.Text = "Computer $ComputerName deleted from SCCM"
}

    else

{
$result_label.ForeColor= "Red"
$result_label.Text = "Computer $ComputerName does not exist in SCCM"
}

$statusBar1.Text = "Operation completed"
}
}

#endregion


$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(5,80)
$OKButton.Size = New-Object System.Drawing.Size(110,23)
$OKButton.Text = "Delete Object"
$OKButton.Add_Click($ping_computer_click)
$Form.Controls.Add($OKButton)

$RemovePXEButton = New-Object System.Windows.Forms.Button
$RemovePXEButton.Location = New-Object System.Drawing.Size(140,80)
$RemovePXEButton.Size = New-Object System.Drawing.Size(200,23)
$RemovePXEButton.Text = "Remove PXE Advertisement"
$RemovePXEButton.Add_Click($ping_computer_click)
$Form.Controls.Add($RemovePXEButton)

$result_label = New-Object System.Windows.Forms.label
$result_label.Location = New-Object System.Drawing.Size(5,65)
$result_label.Size = New-Object System.Drawing.Size(240,30)
$result_label.Text = ""
$Form.Controls.Add($result_label)

$statusBar1 = New-Object System.Windows.Forms.StatusBar
$statusBar1.Name = "statusBar1"
$statusBar1.Text = ""
$form.Controls.Add($statusBar1)

$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter"){& $ping_computer_click}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})
#endregion begin to draw forms

#Show form
$Form.Topmost = $True
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()