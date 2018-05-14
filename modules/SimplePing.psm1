<#
Author:  Thomas Laurenson
Email:   thomas@thomaslaurenson.com
Website: thomaslaurenson.com
Date:    2018/05/11
Description:
SimplePing.psm1 is simple ping module.


Copyright (c) 2018, Thomas Laurenson
###############################################################################
This file is part of vSphereResources.
vSphereResources is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
###############################################################################
#>

Function SimplePing {
   param($InputObject = $null)

   BEGIN {$status = $True}

   PROCESS {
      if ($InputObject -and $_) {
         throw 'ParameterBinderStrings\AmbiguousParameterSet'
      } elseif ($InputObject -or $_) {
         $processObject = $(if ($InputObject) {$InputObject} else {$_})

         if( (Test-Connection $processObject -Quiet -count 1)) {
            $status = $True
         }
         else {
            $status = $False
         }
      }
      else {throw 'ParameterBinderStrings\InputObjectNotBound'}
    }

    # Return True if pings to all machines succeed:
    END {return $status}
}
