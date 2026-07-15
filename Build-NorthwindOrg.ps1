# ============================================================
# Build-NorthwindOrg.ps1
# Creates 25 users + 7 department security groups in Entra ID
# Northwind Botanicals IAM Governance Lab
# ============================================================

$domain = "northwindbotanicals.onmicrosoft.com"

# --- Temporary password for all lab users (they'd reset at first sign-in in real life) ---
$PasswordProfile = @{
    Password                      = "NwLab!Temp2026"
    ForceChangePasswordNextSignIn = $false
}

# --- The 25-person roster ---
$roster = @(
    @{ U="sarah.whitfield"; D="Sarah Whitfield"; T="Chief Executive Officer";        Dept="Executive";              Grp="SG-Executive"  }
    @{ U="marcus.reed";     D="Marcus Reed";     T="Chief Operating Officer";        Dept="Executive";              Grp="SG-Executive"  }
    @{ U="diane.foster";    D="Diane Foster";    T="Chief Financial Officer";        Dept="Executive";              Grp="SG-Executive"  }
    @{ U="priya.nair";      D="Priya Nair";      T="Finance Manager";                Dept="Finance";                Grp="SG-Finance"    }
    @{ U="kevin.alvarez";   D="Kevin Alvarez";   T="Accounts Payable Clerk";         Dept="Finance";                Grp="SG-Finance"    }
    @{ U="rebecca.lin";     D="Rebecca Lin";     T="Controller";                     Dept="Finance";                Grp="SG-Finance"    }
    @{ U="tomas.ortiz";     D="Tomas Ortiz";     T="Payroll Specialist";             Dept="Finance";                Grp="SG-Finance"    }
    @{ U="angela.brooks";   D="Angela Brooks";   T="HR Generalist";                  Dept="Human Resources";        Grp="SG-HR"         }
    @{ U="david.okafor";    D="David Okafor";    T="IT Manager";                     Dept="Information Technology";  Grp="SG-IT"         }
    @{ U="nina.petrova";    D="Nina Petrova";    T="Systems Administrator";          Dept="Information Technology";  Grp="SG-IT"         }
    @{ U="jason.cole";      D="Jason Cole";      T="Help Desk Technician";           Dept="Information Technology";  Grp="SG-IT"         }
    @{ U="laura.chen";      D="Laura Chen";      T="Sales Director";                 Dept="Sales";                  Grp="SG-Sales"      }
    @{ U="michael.grant";   D="Michael Grant";   T="Account Executive";              Dept="Sales";                  Grp="SG-Sales"      }
    @{ U="fatima.hassan";   D="Fatima Hassan";   T="Account Executive";              Dept="Sales";                  Grp="SG-Sales"      }
    @{ U="ryan.mitchell";   D="Ryan Mitchell";   T="Sales Operations Analyst";       Dept="Sales";                  Grp="SG-Sales"      }
    @{ U="emily.carter";    D="Emily Carter";    T="Inside Sales Representative";    Dept="Sales";                  Grp="SG-Sales"      }
    @{ U="carlos.mendez";   D="Carlos Mendez";   T="Operations Manager";             Dept="Operations";             Grp="SG-Operations" }
    @{ U="hannah.kim";      D="Hannah Kim";      T="Logistics Coordinator";          Dept="Operations";             Grp="SG-Operations" }
    @{ U="samuel.adeyemi";  D="Samuel Adeyemi";  T="Procurement Specialist";         Dept="Operations";             Grp="SG-Operations" }
    @{ U="grace.thompson";  D="Grace Thompson";  T="Quality Assurance Analyst";      Dept="Operations";             Grp="SG-Operations" }
    @{ U="luis.ramirez";    D="Luis Ramirez";    T="Warehouse Manager";              Dept="Warehouse";              Grp="SG-Warehouse"  }
    @{ U="derek.wallace";   D="Derek Wallace";   T="Inventory Clerk";                Dept="Warehouse";              Grp="SG-Warehouse"  }
    @{ U="aisha.bello";     D="Aisha Bello";     T="Inventory Clerk";                Dept="Warehouse";              Grp="SG-Warehouse"  }
    @{ U="peter.novak";     D="Peter Novak";     T="Shipping and Receiving Associate"; Dept="Warehouse";            Grp="SG-Warehouse"  }
    @{ U="maria.santos";    D="Maria Santos";    T="Shipping and Receiving Associate"; Dept="Warehouse";            Grp="SG-Warehouse"  }
)

# --- Step 1: Create the 7 department security groups (skip if they already exist) ---
$groupIds = @{}
$deptGroups = $roster.Grp | Sort-Object -Unique
foreach ($g in $deptGroups) {
    $existing = Get-MgGroup -Filter "displayName eq '$g'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Group already exists: $g" -ForegroundColor Yellow
        $groupIds[$g] = $existing.Id
    } else {
        $newGroup = New-MgGroup -DisplayName $g `
            -MailEnabled:$false `
            -MailNickname ($g -replace '[^a-zA-Z0-9]','') `
            -SecurityEnabled:$true
        Write-Host "Created group: $g" -ForegroundColor Green
        $groupIds[$g] = $newGroup.Id
    }
}

# --- Step 2: Create the 25 users and add each to its department group ---
foreach ($p in $roster) {
    $upn = "$($p.U)@$domain"
    $existing = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "User already exists: $upn" -ForegroundColor Yellow
        $user = $existing
    } else {
        $user = New-MgUser -DisplayName $p.D `
            -UserPrincipalName $upn `
            -MailNickname $p.U `
            -AccountEnabled:$true `
            -JobTitle $p.T `
            -Department $p.Dept `
            -PasswordProfile $PasswordProfile
        Write-Host "Created user: $($p.D)  ($upn)" -ForegroundColor Green
    }
    # Add to department group
    try {
        New-MgGroupMember -GroupId $groupIds[$p.Grp] -DirectoryObjectId $user.Id -ErrorAction Stop
    } catch {
        Write-Host "  (already a member of $($p.Grp), skipping)" -ForegroundColor DarkGray
    }
}

Write-Host "`nDone. Created/verified 25 users across 7 department groups." -ForegroundColor Cyan