/*
    Copyright (c) 2014, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2014
* @group Address Management
* @description Supports the automatic scheduling of Seasonal Address updates  
*/ 
public class ADDR_Seasonal_SCHED implements Database.Batchable<SObject>, Schedulable {

    private static final Integer BATCH_SIZE = 10;

    /*******************************************************************************************************
    * @description Schedulable execute method executes this batch job
    ********************************************************************************************************/
    public void execute(SchedulableContext context) {
        Database.executeBatch(new ADDR_Seasonal_SCHED(), BATCH_SIZE);
    }

    /*******************************************************************************************************
    * @description start Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return database.Querylocator  
    ********************************************************************************************************/
    public Database.Querylocator start(Database.BatchableContext bc) {
        final List<String> monthsList = new List<String>{ '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12' };

        // Find all Accounts who have any Seasonal Address that might need updating,
        // since it may need to now become current or inactive, and we don't want to assume the last time this ran.
        // Make sure to include all Billing Address fields, that we will need to look at
        String soql = 'SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLongitude, BillingLatitude';
        if (ADDR_Addresses_TDTM.isStateCountryPicklistsEnabled) {
            soql += ', BillingStateCode, BillingCountryCode';
        }
        soql += ' FROM Account WHERE Id IN (SELECT Household_Account__c FROM Address__c ' +
            ' WHERE Seasonal_Start_Month__c IN :monthsList)';
        return Database.getQueryLocator(soql);
    }

    /*******************************************************************************************************
    * @description execute Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @param scope the list of Account objects to process
    * @return void  
    ********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        ADDR_Addresses_TDTM.batchSeasonalUpdate(scope);
    }

    /*******************************************************************************************************
    * @description finish Method for the Database.Batchable interface
    * @param bc the BatchableContext
    * @return void  
    ********************************************************************************************************/
    public void finish(Database.BatchableContext bc) {

    }   
       
}