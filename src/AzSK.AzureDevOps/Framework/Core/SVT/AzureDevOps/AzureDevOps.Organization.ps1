Set-StrictMode -Version Latest 
class Organization: SVTBase
{    
    [PSObject] $ServiceEndPointsObj = $null
    [PSObject] $OrgPolicyObj = $null
    #TODO: testing below line
    hidden [string] $SecurityNamespaceId;
    Organization([string] $subscriptionId, [SVTResource] $svtResource): Base($subscriptionId,$svtResource) 
    { 
        #TODO: testing
        $this.Test();
        $this.GetOrgPolicyObject()
    }

    GetOrgPolicyObject()
    {
        $apiURL = "https://{0}.vsaex.visualstudio.com/_apis/Contribution/dataProviders/query?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
        #TODO: testing adding below line commenting above line
        #$apiURL = "https://dev.azure.com/{0}/_apis/Contribution/HierarchyQuery?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);

        $orgUrl = "https://{0}.visualstudio.com" -f $($this.SubscriptionContext.SubscriptionName);
        $inputbody =  "{'contributionIds':['ms.vss-org-web.collection-admin-policy-data-provider'],'context':{'properties':{'sourcePage':{'url':'$orgUrl/_settings/policy','routeId':'ms.vss-admin-web.collection-admin-hub-route','routeValues':{'adminPivot':'policy','controller':'ContributedPage','action':'Execute'}}}}}" | ConvertFrom-Json
        
        $responseObj = [WebRequestHelper]::InvokePostWebRequest($apiURL,$inputbody);
      
        if([Helpers]::CheckMember($responseObj,"data") -and $responseObj.data.'ms.vss-org-web.collection-admin-policy-data-provider')
        {
            $this.OrgPolicyObj = $responseObj.data.'ms.vss-org-web.collection-admin-policy-data-provider'.policies
        }
    }

    #TODO:   
    hidden Test()
    {
        <# 
        $apiURL = "https://dev.azure.com/{0}/_apis/securitynamespaces?api-version=5.0" -f $($this.SubscriptionContext.SubscriptionName)
        $securityNamespacesObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);
        $this.SecurityNamespaceId = ($securityNamespacesObj | Where-Object { ($_.Name -eq "Build") -and ($_.actions.name -contains "ViewBuilds")}).namespaceId

        # Get build object
        $apiURL = $this.ResourceContext.ResourceId
        $this.BuildObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);

        if(($this.BuildObj | Measure-Object).Count -gt 0)
        {
           if($this.BuildObj.repository.type -eq 'TfsGit'){
               Write-Output 'internal'
           }
        } #>

       $auditapi ="https://auditservice.dev.azure.com/{0}/_apis/audit/auditlog?api-version=5.1-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
       $responseObj = [WebRequestHelper]::InvokeGetWebRequest($auditapi);

        $url= "https:/.dev.azure.com/{0}/_apis/notification/eventtypes?api-version=5.1" -f $($this.SubscriptionContext.SubscriptionName);
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($url);

       <# if($responseObj.principalName -contains 'Project Collection Service Accounts'){
        #$controlResult.AddMessage([VerificationResult]::Failed, "Organization is configured with Project Collection Service Accounts.");
        Write-Output 'found';
       }  #>     
    }

    #TODO:   
    hidden [ControlResult] CheckProCollSerAcc([ControlResult] $controlResult)
    {

       # $apiURL2 = "https://{0}.vsaex.visualstudio.com/_apis/Contribution/dataProviders/query?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
       # $apiURL3 ="https://dev.azure.com/{0}/_apis/Contribution/HierarchyQuery?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
       # #TODO: testing adding below line commenting above line
       # #$apiURL = "https://dev.azure.com/{0}/_apis/Contribution/HierarchyQuery?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);

       # $orgUrl2 = "https://{0}.visualstudio.com" -f $($this.SubscriptionContext.SubscriptionName);
       # $orgUrl3 = "https://dev.azure.com/{0}/_settings/groups" -f $($this.SubscriptionContext.SubscriptionName);
       # 
       # $inputbody2 =  "{'contributionIds':['ms.vss-org-web.collection-admin-groups-data-provider'],'context':{'properties':{'sourcePage':{'url':'$orgUrl2/_settings/groups','routeId':'ms.vss-admin-web.collection-admin-hub-route','routeValues':{'adminPivot':'groups','controller':'ContributedPage','action':'Execute'}}}}}" | ConvertFrom-Json
        
        $url= "https://vssps.dev.azure.com/{0}/_apis/graph/groups?api-version=5.1-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($url);

       if($responseObj.principalName -contains 'Project Collection Service Accounts'){
        $controlResult.AddMessage([VerificationResult]::Failed, "Organization is configured with Project Collection Service Accounts.");
       }
       else {
        $controlResult.AddMessage([VerificationResult]::Passed, "Project Collection Service Accounts does not hass access to Organization.");

       }
<# 
        $inputbody3 =  "{
            'contributionIds':['ms.vss-admin-web.org-admin-permissions-pivot-data-provider'],
            'context':{
            'properties':{
                'sourcePage':{
                    'url':'$orgUrl3/_settings/groups',
                    'routeId':'ms.vss-admin-web.collection-admin-hub-route',
                    'routeValues':{
                        'adminPivot':'permissions',
                        'controller':'ContributedPage',
                        'action':'Execute'
                        }}}}}"

                        try {
                            $responseObj2 = [WebRequestHelper]::InvokePostWebRequest($apiURL2,$inputbody2);
                            $responseObj2 = [WebRequestHelper]::InvokePostWebRequest($apiURL2,$inputbody3);
                        }
                        catch {
                            try {
                                $urlll = "https://dev.azure.com/{0}/_settings/permissions?__rt=fps&__ver=2" -f $($this.SubscriptionContext.SubscriptionName);
                                $responseObj2 = [WebRequestHelper]::InvokeGetWebRequest($urlll);
                                Write-Host $responseObj2;
                            }
                            catch {
                                $urr = "https://dev.azure.com/{0}/_settings/groups?__rt=fps&__ver=2" -f $($this.SubscriptionContext.SubscriptionName);
                               try {
                                $responseObj2 = [WebRequestHelper]::InvokeGetWebRequest($urr);
                               }
                               catch {
                                $responseObj2 = [WebRequestHelper]::InvokePostWebRequest($apiURL3,$inputbody3);
                               }
                               
                              
                            }
                           
                        } #>
        

        if([Helpers]::CheckMember($responseObj,"data") -and $responseObj.data.'ms.vss-org-web.collection-admin-policy-data-provider')
        {
            $this.OrgPolicyObj = $responseObj.data.'ms.vss-org-web.collection-admin-policy-data-provider'.policies
        }

        return $controlResult
    }

    hidden [ControlResult] CheckAADConfiguration([ControlResult] $controlResult)
    {

        $apiURL = "https://{0}.visualstudio.com/_apis/Contribution/HierarchyQuery?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
        $inputbody =  '{"contributionIds":["ms.vss-admin-web.organization-admin-aad-component","ms.vss-admin-web.organization-admin-aad-data-provider"],"dataProviderContext":{"properties":{}}}' | ConvertFrom-Json
        $responseObj = [WebRequestHelper]::InvokePostWebRequest($apiURL,$inputbody);

        if([Helpers]::CheckMember($responseObj,"dataProviders") -and $responseObj.dataProviders.'ms.vss-admin-web.organization-admin-aad-data-provider' -and [Helpers]::CheckMember($responseObj.dataProviders.'ms.vss-admin-web.organization-admin-aad-data-provider'.orgnizationTenantData,"displayName"))
        {
            $controlResult.AddMessage([VerificationResult]::Passed,
                                                "Organization is configured with ($($responseObj.dataProviders.'ms.vss-admin-web.organization-admin-aad-data-provider'.orgnizationTenantData.displayName)) directory");
        }
        else {
            $controlResult.AddMessage([VerificationResult]::Failed,
                                                "AAD is not configured on Organization");
        }
        return $controlResult
    }


    hidden [ControlResult] CheckAltAuthSettings([ControlResult] $controlResult)
    {
       if([Helpers]::CheckMember($this.OrgPolicyObj,"applicationConnection"))
       {
           try {                       
               #https://devblogs.microsoft.com/devops/azure-devops-will-no-longer-support-alternate-credentials-authentication/
                $altAuthObj = $this.OrgPolicyObj.applicationConnection | Where-Object {$_.Policy.Name -eq "Policy.DisallowBasicAuthentication"}
                 if(($altAuthObj | Measure-Object).Count -gt 0)
                {
                     if($altAuthObj.policy.effectiveValue -eq $false )
                     {
                         $controlResult.AddMessage([VerificationResult]::Passed,
                                                     "Alternate authentication is disabled on Organization");
                     }
                     else {
                         $controlResult.AddMessage([VerificationResult]::Failed,
                                                     "Alternate authentication is enabled on Organization");
                     }
                 }
             }
             catch {
                $controlResult.AddMessage([VerificationResult]::Passed,
                "Alternate authentication is no longer supported in devops");
             }
        }

        return $controlResult
    }

    hidden [ControlResult] CheckExternalUserPolicy([ControlResult] $controlResult)
    {
       if([Helpers]::CheckMember($this.OrgPolicyObj,"user"))
       {
           $guestAuthObj = $this.OrgPolicyObj.user | Where-Object {$_.Policy.Name -eq "Policy.DisallowAadGuestUserAccess"}
            if(($guestAuthObj | Measure-Object).Count -gt 0)
           {
                if($guestAuthObj.policy.effectiveValue -eq $false )
                {
                    $controlResult.AddMessage([VerificationResult]::Passed,
                                                "External guest access is disabled on Organization");
                }
                else {
                    $controlResult.AddMessage([VerificationResult]::Failed,
                                                "External guest access enabled on Organization");
                }
            }
       }
        return $controlResult
    }

    hidden [ControlResult] CheckPublicProjectPolicy([ControlResult] $controlResult)
    {
       if([Helpers]::CheckMember($this.OrgPolicyObj,"security"))
       {
           $guestAuthObj = $this.OrgPolicyObj.security | Where-Object {$_.Policy.Name -eq "Policy.AllowAnonymousAccess"}
            if(($guestAuthObj | Measure-Object).Count -gt 0)
           {
                if($guestAuthObj.policy.effectiveValue -eq $false )
                {
                    $controlResult.AddMessage([VerificationResult]::Passed,
                                                "Public projects are disabled on Organization");
                }
                else {
                    $controlResult.AddMessage([VerificationResult]::Failed,
                                                "Public projects are enabled on Organization");
                }
            }
       }
        return $controlResult
    }


    hidden [ControlResult] ValidateInstalledExtensions([ControlResult] $controlResult)
    {
       try {
           
        $apiURL = "https://extmgmt.dev.azure.com/{0}/_apis/extensionmanagement/installedextensions?api-version=4.1-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);
        
        if(($responseObj | Measure-Object).Count -gt 0 )
        {
                $controlResult.AddMessage("No. of extensions installed:" + $responseObj.Count)
                $extensionList =  $responseObj | Select-Object extensionName,publisherName,version 
                $whiteListedExtensions = $extensionList | Where-Object {$_.publisherName -in $this.ControlSettings.Organization.WhitelistedExtensionPublishers }
                $NonwhiteListedExtensions = $extensionList | Where-Object {$_.publisherName -notin $this.ControlSettings.Organization.WhitelistedExtensionPublishers }
                
            $controlResult.AddMessage([VerificationResult]::Verify, "Verify below installed extensions");  
            $controlResult.AddMessage("Whitelisted extensions (from trustred publisher)", $whiteListedExtensions);

            $controlResult.AddMessage("Non-Whitelisted extensions", $NonwhiteListedExtensions);

        }
        else {
            $controlResult.AddMessage([VerificationResult]::Passed, "No extensions found");
        }

       }
       catch {
        $controlResult.AddMessage([VerificationResult]::Manual, "Could not evaluate extensions.");
       }

      return $controlResult
    }

    hidden [ControlResult] ValidateSharedExtensions([ControlResult] $controlResult)
    {
        $apiURL = "https://{0}.extmgmt.visualstudio.com/_apis/Contribution/dataProviders/query?api-version=5.0-preview.1" -f $($this.SubscriptionContext.SubscriptionName);
        $inputbody =  '{
                "contributionIds": [
                "ms.vss-extmgmt-web.ems-service-context",
                "ms.vss-extmgmt-web.manageExtensions-collection-data-provider",
                "ms.vss-extmgmt-web.manageExtensions-collection-scopes-data-provider"
            ]
        }' | ConvertFrom-Json
        $responseObj = [WebRequestHelper]::InvokePostWebRequest($apiURL,$inputbody);

        if([Helpers]::CheckMember($responseObj,"data") -and $responseObj.data.'ms.vss-extmgmt-web.manageExtensions-collection-data-provider')
        {
            $sharedExtensions = $responseObj.data.'ms.vss-extmgmt-web.manageExtensions-collection-data-provider'.sharedExtensions

            if(($sharedExtensions | Measure-Object).Count -gt 0)
            {
                $controlResult.AddMessage("No. of shared installed:" + $sharedExtensions.Count)
                $extensionList =  $sharedExtensions | Select-Object extensionName,displayName,@{ Name = 'publisherName'; Expression = {  $_. publisher.displayName}} 
                $controlResult.AddMessage([VerificationResult]::Verify,
                                                "Review below shared extensions",$extensionList);  

            }
        }
        return $controlResult
    }

    hidden [ControlResult] CheckGuestIdentities([ControlResult] $controlResult)
    {
        try {
              $apiURL = "https://{0}.vsaex.visualstudio.com/_apis/UserEntitlements?top=100&filter=userType+eq+%27guest%27&api-version=5.0-preview.2" -f $($this.SubscriptionContext.SubscriptionName);
              $responseObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);
      
              if( $responseObj -ne $null -and ($responseObj | Measure-Object).Count -gt 0 )
              {
                  if( [Helpers]::CheckMember($responseObj[0], 'members') -and  ($responseObj.members | Measure-Object).Count -gt 0)
                  {
                      $controlResult.AddMessage("No. of guest identities present:" + $responseObj.members.Count)
                      $extensionList =  $responseObj.members | Select-Object @{Name="IdenityType"; Expression = {$_.user.subjectKind}},@{Name="DisplayName"; Expression = {$_.user.displayName}}, @{Name="MailAddress"; Expression = {$_.user.mailAddress}},@{Name="AccessLevel"; Expression = {$_.accessLevel.licenseDisplayName}},@{Name="LastAccessedDate"; Expression = {$_.lastAccessedDate}} | Format-Table
                      $controlResult.AddMessage([VerificationResult]::Verify, "Verify below guest identities",$extensionList);          
                  }
                  else {
                      $controlResult.AddMessage([VerificationResult]::Passed, "No guest identities found");
                  }
              }
            }
            catch {
                $controlResult.AddMessage([VerificationResult]::Manual, "No guest identities found");
            } 

        return $controlResult
    }

    hidden [ControlResult] CheckExtensionManagers([ControlResult] $controlResult)
    {

        $apiURL = "https://{0}.extmgmt.visualstudio.com/_apis/securityroles/scopes/ems.manage.ui/roleassignments/resources/ems-ui" -f $($this.SubscriptionContext.SubscriptionName);
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);
        if(($responseObj | Measure-Object).Count -gt 0 )
        {
                $controlResult.AddMessage("No. of extension managers present:" + $responseObj.Count)
                $extentionManagerList =  $responseObj | Select-Object @{Name="IdentityName"; Expression = {$_.identity.displayName}},@{Name="Role"; Expression = {$_.role.displayName}}
                $controlResult.AddMessage([VerificationResult]::Verify,
                                                "Verify below extension managers",$extentionManagerList);          
        }
        else {
            $controlResult.AddMessage([VerificationResult]::Passed,
                                                "No extension manager found");
        }
        return $controlResult
    }

    hidden [ControlResult] CheckInActiveUsers([ControlResult] $controlResult)
    {

        $apiURL = "https://{0}.vsaex.visualstudio.com/_apis/UserEntitlements?top=50&filter=&sortOption=lastAccessDate+ascending" -f $($this.SubscriptionContext.SubscriptionName);
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);

        if($responseObj.Count -gt 0)
        {
            $inactiveUsers =  @()
            $responseObj[0].items | ForEach-Object { 
                if([datetime]::Parse($_.lastAccessedDate) -lt ((Get-Date).AddDays(-$($this.ControlSettings.Organization.InActiveUserActivityLogsPeriodInDays))))
                {
                    $inactiveUsers+= $_
                }                
            }
            if(($inactiveUsers | Measure-Object).Count -gt 0)
            {
                if($inactiveUsers.Count -eq 50)
                {
                    $controlResult.AddMessage("Displaying top 50 inactive users")
                }
                $inactiveUsersNames = ($inactiveUsers | Select-Object -Property @{Name="Name"; Expression = {$_.User.displayName}},@{Name="mailAddress"; Expression = {$_.User.mailAddress}})
                $controlResult.AddMessage([VerificationResult]::Failed,
                                        "Review inactive users present on Organization",$inactiveUsersNames);
            }
            else {
                $controlResult.AddMessage([VerificationResult]::Passed,
                                        "No inactive users found")   
            }
        }
        else
        {
            $controlResult.AddMessage([VerificationResult]::Passed,
                                        "No inactive users found");
        }
        
        return $controlResult;
    }

    hidden [ControlResult] CheckDisconnectedIdentities([ControlResult] $controlResult)
    {
        $apiURL = "https://{0}.visualstudio.com/_apis/OrganizationSettings/DisconnectedUser" -f $($this.SubscriptionContext.SubscriptionName);
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);
        
        try {
           if ([Helpers]::CheckMember($responseObj,"users")) {
               if(($responseObj.users | Measure-Object).Count -gt 0 )  
               {
        
                       $UsersNames = ($responseObj.users | Select-Object -Property @{Name="Name"; Expression = {$_.displayName}},@{Name="mailAddress"; Expression = {$_.preferredEmailAddress}})
                       $controlResult.AddMessage([VerificationResult]::Failed, "Remove below disconnected user access from Organization",$UsersNames);  
               }
               else
               {
                   $controlResult.AddMessage([VerificationResult]::Passed, "No diconnected users found");
               }   
              } 
        }
        catch {
            $controlResult.AddMessage([VerificationResult]::Passed, "No diconnected users found");
        }
        
       
        return $controlResult;
    }

    
}