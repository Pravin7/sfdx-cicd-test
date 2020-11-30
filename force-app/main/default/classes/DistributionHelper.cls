public with sharing class DistributionHelper {
	
	public static void insertInvestmentDistribution(List<Distribution__c> distroIdsList) {
		
	        Map<String, Distribution__c> distroIdVsDistroNameMap = new Map<String, Distribution__c>();
	        Map<String, Investment__c> investmentMap = new Map<String, Investment__c>();
	        Map<String,List<Product__c>> investorIdvsProductsMap = new Map<String, List<Product__c>>();
	        Map<String,List<Investor__c>> distroVsInvestorsMap = new Map<String,List<Investor__c>>();
	        
	        for (Distribution__c dist: distroIdsList) {
	        	distroIdVsDistroNameMap.put(dist.id,dist);        	
	        }	        
	        for (Distribution__c distro : [SELECT Id, Investment__c, Investment__r.Name,
	    									distribution_per_performance_unit__c,
	    									distribution_per_ordinary_unit__c, year__c,
	   										period__c, Date_of_Distribution__c 
	   										FROM Distribution__c WHERE Id IN :distroIdVsDistroNameMap.keyset()]) {
				distroIdVsDistroNameMap.put(distro.id,distro);
				investmentMap.put(distro.investment__c,null);
	        }
	
	    	List<Investment__c> inviList = [SELECT Id, Name, (SELECT Id, Name FROM Investors__r),
	    									(SELECT Id, Name FROM Distributions__r) FROM Investment__c 
	    									WHERE Id IN : investmentMap.keySet()];        
	                        
	        for (Distribution__c distro : distroIdVsDistroNameMap.values()) {        		
	        	for (Investment__c investement : inviList) {
	        		System.debug('##_'+investement.Investors__r);
	        		if (null != investement.Investors__r && !investement.Investors__r.isEmpty()) {
	        			distroVsInvestorsMap.put(distro.id, new List<Investor__c>(investement.Investors__r));	        			
	        			for(Investor__c investor : investement.Investors__r) {  
	        				System.debug('###_'+investor.name);
	        				investorIdvsProductsMap.put(investor.id, new List<Product__c>());
	        					// populating investorIdvsProductsMap to use keyset in products query
	        			}        			
	        		}
	        	}
	        }
	        
	    	List<Product__c> prodList = [SELECT Id, Type_of_Unit__c, Number_of_Performance_Units__c, Investor__c,
	   									Number_of_Ordinary_Units__c, Investment_Date__c  FROM Product__c 
	   									WHERE Investor__c IN : investorIdvsProductsMap.keySet()]; 
	    	
	    	for (Product__c prod : prodList) {
	    		if (null != prod.Investor__c) {
	    		//populating investor vs product map       			    			
	    			List<Product__c> prodListTemp = investorIdvsProductsMap.get(prod.Investor__c);  	
	    			prodListTemp.add(prod);
	    			investorIdvsProductsMap.put(prod.Investor__c, prodListTemp);
	    		}
	    	}
			calculateDistPerOrdinaryUnit(distroIdVsDistroNameMap, distroVsInvestorsMap , investorIdvsProductsMap);     
	}

	public static void calculateDistPerOrdinaryUnit(Map<String, Distribution__c> distroIdVsDistroNameMap,
													Map<String, List<Investor__c>> distroVsInvestorsMap,
													MAP<String,LIST<Product__c>> investorIdvsProductsMap) {
														
			List<Investor_Distribution__c> invDistroList = new List<Investor_Distribution__c>();													
			for (String distroId : distroVsInvestorsMap.keySet()) {
				if (!distroVsInvestorsMap.containsKey(distroId)) {
					continue;
				}
				// createInvestorDistribution for each investor
				for (Investor__c investor : distroVsInvestorsMap.get(distroId)) {
					Investor_Distribution__c invDistro = createInvestorDistribution(investor, distroId,
																					distroIdVsDistroNameMap,
																					investorIdvsProductsMap);
					if (null != invDistro) {
						invDistroList.add(invDistro);
					}
				}			
			}
			try {
				insert invDistroList;
			} catch (Exception e) {
				System.debug('Exception Occured ## ' +e.getMessage());
			}
			
	}
	
	public static Investor_Distribution__c createInvestorDistribution(Investor__c investor, String distroId,
														Map<String, Distribution__c> distroIdVsDistroNameMap,
														Map<String,List<Product__c>> investorIdvsProductsMap) {
															
			if (!investorIdvsProductsMap.containsKey(investor.id)) {
				return null;
			}
			if (!distroIdVsDistroNameMap.containsKey(distroId)) {
				return null;
			}
			
			Distribution__c distro = distroIdVsDistroNameMap.get(distroId);
			Investor_Distribution__c idistro = new Investor_Distribution__c();		
			Decimal total_performance_unit_dist = 0;
			Decimal total_ordinary_unit_dist = 0;
			Decimal distribution_per_performance_unit = distro.distribution_per_performance_unit__c;
			Decimal distribution_per_ordinary_unit = distro.distribution_per_ordinary_unit__c;
			
			Decimal sum_performance_unit_dist = 0;
			Decimal sum_ordinary_unit_dist = 0;	
				
			for (Product__c product : investorIdvsProductsMap.get(investor.id)) {					// Products per investor				
				if (product.investment_date__c <= distro.Date_of_Distribution__c) {
					if (product.type_of_unit__c == 'Ordinary') {
						sum_performance_unit_dist += product.number_of_performance_units__c;
					} else {
						sum_ordinary_unit_dist += product.number_of_ordinary_units__c;
					}
				}								
			}			
			// calculating total_performance_unit_dist and total_ordinary_unit_dist from disrubuition rates
			if (distribution_per_performance_unit != null) {
				total_performance_unit_dist = sum_performance_unit_dist  * distribution_per_performance_unit;
			}
			if (distribution_per_ordinary_unit != null) {
				total_ordinary_unit_dist =  sum_ordinary_unit_dist * distribution_per_ordinary_unit;
			}			
			// setting Investor_Distribution__c values
			idistro.total_ordinary_unit_dist__c = total_ordinary_unit_dist;
			idistro.total_performance_unit_dist__c = total_performance_unit_dist;
			idistro.year__c = distro.year__c;
			idistro.investor__c = investor.id;
			idistro.period__c = distro.period__c;
			return idistro;		
		}
}