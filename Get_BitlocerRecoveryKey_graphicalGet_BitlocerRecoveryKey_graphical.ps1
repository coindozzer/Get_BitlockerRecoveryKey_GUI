#XAML Frame
Add-Type -AssemblyName PresentationFramework
$ErrorActionPreference = "Continue"
[xml]$xaml = @"
<Window x:Class="BitLockerRecoveryFrame.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:BitLockerRecoveryFrame"
        mc:Ignorable="d"
        Title="Bitlocker Recoverykey Getter" Height="450" Width="800" MinWidth="810" MinHeight="460">
    <Grid>
        <Button x:Name="GetKey" Content="Get Recovery Key" HorizontalAlignment="Left" Margin="10,0,0,20" VerticalAlignment="Bottom" Width="130" Height="40"/>
        <TextBox x:Name="EnterBox" HorizontalAlignment="Left" Height="24" Margin="10,40,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="130" FontSize="16" MaxLength="6"/>
        <TextBox x:Name="OutputBox" Margin="155,10,20,20" TextWrapping="Wrap" Text=""/>
        <Label Content="Enter PC in Box" HorizontalAlignment="Left" Margin="10,14,0,0" VerticalAlignment="Top" Width="130"/>

    </Grid>
</Window>
"@ -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window' #-replace wird benötigt, wenn XAML aus Visual Studio kopiert wird.#> 

#declare Reader and Window
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.markup.xamlreader]::Load($reader)

#assign buttons and boxes
$getPcButton = $window.FindName("GetKey")
$pathTextBox = $window.FindName("EnterBox")
$pathTextBox2 = $window.FindName("OutputBox")


#logic
$getPcButton.Add_Click({
        try {
            $pathTextBox2.Text = ""
            if (Get-ADComputer -Identity $pathTextBox.Text) { 
                try {
                    $computer = Get-ADComputer -Identity $pathTextBox.Text
                    $recoveryInformation = Get-ADObject -Filter 'objectClass -eq "msFVE-RecoveryInformation"' -SearchBase $computer.DistinguishedName -Properties *
                    #$pathTextBox2.Text = $recoveryInformation.'msFVE-RecoveryPassword'
                    foreach ($item in $recoveryInformation) {
                        $pathTextBox2.Text += ("Creation Time: {0}`r`n Key: {1} `r`n " -f $item.createTimeStamp,$item.'msFVE-RecoveryPassword')
                    }
                }
                catch {
                    $pathTextBox2.Text = "Fehler bei Suche für Key"
                }
            }
        }
        catch {
            $pathTextBox2.Text = "PC nicht gefunden"  
        }
         
    })

#show window
$window.ShowDialog()