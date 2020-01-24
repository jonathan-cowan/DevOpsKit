Set-StrictMode -Version Latest 

class APIManagementFix: FixServicesBase
{       
	[PSObject] $ResourceObject = $null;
	APIManagementFix([string] $subscriptionId, [ResourceConfig] $resourceConfig, [string] $resourceGroupName): 
	Base($subscriptionId, $resourceConfig, $resourceGroupName) 
 { }

	[PSObject] FetchAppServiceObject()
	{
		if (-not $this.ResourceObject)
		{
			$this.ResourceObject = Get-AzWebApp -Name $this.ResourceName -ResourceGroupName $this.ResourceGroupName
			Get-AzResource -Name $this.ResourceName  `
				-ResourceType $this.ResourceType `
				-ResourceGroupName $this.ResourceGroupName
		}

		return $this.ResourceObject;
	}

	[MessageData[]] DisableUnsecureProtocolsAndCiphersConfiguration([PSObject] $parameters)
 {
		[MessageData[]] $detailedLogs = @();
			
		$detailedLogs += [MessageData]::new("Setting up minimum TLS Version to $($this.ControlSettings.AppService.TLS_Version) for app service [$($this.ResourceName)]...");
		
		# $params = @{
		# 	ApiVersion        = '2018-02-01'
		# 	ResourceName      = '{0}/web' -f $this.ResourceName
		# 	ResourceGroupName = $this.ResourceGroupName
		# 	PropertyObject    = @{ minTlsVersion = $this.ControlSettings.AppService.TLS_Version }
		# 	ResourceType      = 'Microsoft.Web/sites/config'
		# }
				
		# $result = Set-AzResource @params -ErrorAction Stop

		$detailedLogs += [MessageData]::new("Minimum TLS Version has been set to $($this.ControlSettings.AppService.TLS_Version) for app service [$($this.ResourceName)]", $result);
		
		return $detailedLogs;
	}
}
