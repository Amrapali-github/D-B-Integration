public class DNBAPIDataObjects {
    
    //public Integer displaySequence {get;set;}
    public DNBOrganization organization {get;set;}
    
    public class DNBNotificationPull{
        public List<DNBNotification> notifications {get;set;}
        //public DNBPullInformation information {get;set;}       
    }
    /*
    public class DNBPullInformation{
        public string code {get;set;}
        public string message {get;set;}
    }
    */
    public class DNBNotification{        
        public string type {get;set;}
        public DNBOrganization organization {get;set;}
        public List<DNBNotificationElement> elements {get;set;}
    }
    
    public class DNBNotificationElement{
        public string element {get;set;}
        public List<string> previous {get;set;}
        public List<string> current {get;set;}
        public string timeStamp {get;set;}   
    }
    
    public class DNBError{
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
        public List<DNBErrorDetails> errorDetails {get;set;}
    }
    
    public class DNBErrorDetails{
        public string parameter {get;set;}
        public string description {get;set;}
        public string errors {get;set;}
    }
    
    public class DNBOrganization{
        //present in all data blocks
        public String duns {get;set;}
        public String cmzDuns {get; set;}
        public String countryISOAlpha2Code {get; set;}
        public String primaryName {get;set;}
        
        //companyinfo data block
        public String registeredName {get; set;}
        //public String defaultCurrency {get; set;}
        //public Boolean isForbesLargestPrivateCompaniesListed {get; set;}
        //public Boolean isFortune1000Listed {get; set;}
        //public Boolean isNonClassifiedEstablishment {get; set;}
        //public String startDate {get; set;}
        //public String incorporatedDate {get; set;}
        //public String controlOwnershipDate {get; set;}
        //public Boolean isAgent {get; set;}
        //public Boolean isImporter {get; set;}
        //public Boolean isExporter {get; set;}
        //public Boolean isSmallBusiness {get; set;}
        //public Boolean isStandalone {get; set;}       
        //public DNBDunsControlStatus dunsControlStatus {get;set;}      
        //public List<DNBTradeStyleName> tradeStyleNames {get;set;}
        public List<DNBWebsiteAddress> websiteAddress {get;set;}
        //public List<DNBEmail> email {get;set;}
        public List<DNBTelephoneNumber> telephone {get;set;}        
        public DNBAddress primaryAddress {get;set;}
        public DNBAddress registeredAddress {get;set;}
        public DNBAddress mailingAddress {get;set;}
        //public List<DNBAddress> multilingualPrimaryAddress {get;set;}
        //public List<DNBStockExchanges> stockExchanges {get;set;}
        public List<DNBRegistrationNumbers> registrationNumbers {get;set;}
        //public List<DNBActivities> activities {get;set;}
        //public List<DNBBanks> banks {get;set;}
        public DNBBusinessEntityType businessEntityType {get;set;}
        //public DNBBusinessTrustIndex businessTrustIndex {get;set;}
        //public DNBCharterType charterType {get;set;}
        //public DNBDomesticUltimate domesticUltimate {get;set;}
        //public DNBEmployerDesignation employerDesignation {get;set;}
        public List<DNBFinancials> financials {get;set;}
        public DNBGlobalUltimate globalUltimate {get;set;}
        public List<DNBIndustryCodes> industryCodes {get;set;}
        //public DNBLegalForm legalForm {get;set;}
        //public List<DNBMultilingualRegisteredNames> multilingualRegisteredNames {get;set;}
        //public List<DNBMultilingualSearchNames> multilingualSearchNames {get;set;}
        //public List<DNBNumberOfEmployees> numberOfEmployees {get;set;}
        //public DNBOrganizationSizeCategory organizationSizeCategory {get;set;}
        //public DNDPreferredLanguage preferredLanguage {get;set;}
        public DNBIndustryCode primaryIndustryCode {get;set;}
        //public List<DNBUnspscCodes> unspscCodes {get;set;} 
        
        //event filings data block
        //public DNBAwards awards {get;set;}
        //public DNBFinancingEvents financingEvents {get;set;}
        //public boolean hasCompanyMoved {get;set;}
        //public DNBLegalEvents legalEvents {get;set;}
        //public DNBSignificantEvents significantEvents {get;set;}
        //public DNBViolations violations {get;set;}
        
        //hierarachy connections data block        
        public DNBCorporateLinkage corporateLinkage {get;set;}
        //public integer industrialPlantsCount {get;set;} 
        
        //payment insight data block
        public List<DNBBusinessTrading> businessTrading {get;set;}
        
        //principal contacts data block
        public DNBMostSeniorPrincipal mostSeniorPrincipal {get;set;}
        
        //company financials data block
        public DNBFinancials latestFinancials {get;set;}
        //public List<DNBFinancials> previousFinancials {get;set;}
        //public decimal monthlySalesPerEmployee {get;set;}
        //public decimal monthlyProfitsPerEmployee {get;set;}
        
        //financial strength insights data block
        public DNBAssessment dnbAssessment {get;set;}
        //public boolean isDeterioratingBusines {get;set;}
        //public boolean isHighRiskBusiness {get;set;}
        //public DNBLayOffScore layOffScore {get;set;}
        //public DNBTsrRating tsrRating {get;set;}
        
        //miscellaneous
        //public string domain {get;set;}

        //UI state
        public string duplicateLink {get; set;}
        public string duplicateCMZLink {get; set;} 
        
        //account create variable
        public string recordTypeId {get; set;}
                
    }    
    /*
    public class DNBDunsControlStatus{
        //companyInfo data block
        public boolean isMarketable {get;set;} 
        public boolean isTelephoneDisconnected {get;set;} 
        public boolean isMailUndeliverable {get;set;} 
        public boolean isDelisted {get;set;} 
        public String firstReportDate {get;set;}
        public Boolean isSelfRequestedDUNS {get;set;}
        public String selfRequestDate {get;set;}
        public DNBOperatingStatus operatingStatus {get;set;}
        public DNBOperatingStatus operatingSubStatus {get;set;}
        public DNBOperatingStatus detailedOperatingStatus {get;set;}
        public List<DNBSubjectHandlingDetails> subjectHandlingDetails {get;set;}
        public DNBRecordClass DNBRecordClass {get;set;}
        public boolean isOutOfBusiness {get;set;}        
    }
    
    public class DNBOperatingStatus{
        public String description {get;set;}
        public Integer dnbCode {get;set;}
        public String startDate {get;set;}
    }
    
    public class DNBSubjectHandlingDetails {
        public string description {get;set;}
        public Integer dnbCode {get;set;}
    }
    
    public class DNBRecordClass {
        public string description {get;set;}
        public Integer dnbCode {get;set;}
    }
    */
    public class DNBSummary{
        //public String text {get;set;}
        //public DNBTextType testType {get;set;} 
        public integer paydexScore  {get;set;}
        //public integer paymentBehaviorDays {get;set;}
        //public DNBPaymentBehaviorResult paymentBehaviorResult {get;set;}
        //public DNBDataCoverage dataCoverage {get;set;}
        //public integer totalExperiencesCount  {get;set;}
    }
    /*
    public class DNBPaymentBehaviorResult{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBDataCoverage{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBTextType{
        public string description {get;set;}
        public Integer dnbCode {get;set;}   
    }
    
    public class DNBTradeStyleName{
        public string name {get;set;}
        public Integer priority {get;set;}
    }
    */
    public class DNBWebsiteAddress{
        public string url {get;set;}
        //public string domainName {get;set;}
    }
    /*
    public class DNBEmail{
        public string address {get;set;}
    }
    
    */
    public class DNBTelephoneNumber{
        public string telephoneNumber {get;set;}
        public string isdCode {get;set;}
    }
    
    public class DNBAddress{
        //public DNBLanguage language {get;set;}
        public DNBAdressCountry addressCountry {get;set;} 
        public DNBContinentalRegion continentalRegion {get;set;}
        public DNBAddressLocality addressLocality {get;set;}
        //public string minorTownName {get;set;}
        public DNBAddressRegion addressRegion {get;set;}
        public DNBAddressCounty addressCounty {get;set;}
        public string postalCode {get;set;}
        //public DNBPostalCodePosition postalCodePosition{get;set;}
        public DNBStreetAddress streetAddress {get;set;}
        //public DNBPostOfficeBox postOfficeBox {get;set;}
        public string streetNumber {get;set;}
        public string streetName {get;set;}        
        //public Decimal latitute {get;set;}
        //public Decimal longitude {get;set;}   
        //public boolean isManufacturingLocation {get;set;}
        //public boolean isRegisteredAddress {get;set;}
        //public boolean isResidentialAddress {get;set;} 
        //public string postalRoute {get;set;}
        //public DNDGeographicalPrecision geographicalPrecision {get;set;}
        //public List<DNBStandardAddressCodes> standardAddressCodes {get;set;}
        //public DNBStatisticalArea statisticalArea {get;set;}
    }
    /*
    public class DNBLanguage{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    */
    public class DNBContinentalRegion{
        public string name {get;set;}
    }
    
    public class DNBAdressCountry{
        public string isoAlpha2Code {get;set;}
        public string name {get;set;}
    }
    
    public class DNBAddressLocality{
        public string name {get;set;}
    }
    
    public class DNBAddressRegion{
        public string name {get;set;}
        public string abbreviatedName {get;set;}
    }
        
    public class DNBAddressCounty{
        public string name {get;set;}
    }
    /*
    public class DNBPostalCodePosition{
        public string description {get;set;}
        public Integer dnbCode {get;set;}   
    }
    */
    public class DNBStreetAddress{
        public string line1 {get;set;}
        public string line2 {get;set;} 
        public string line3 {get;set;}
        public string line4 {get;set;}
    }
    /*
    public class DNBPostOfficeBox{
        public string postOfficeBoxNumber {get;set;}
        public string typeDescription {get;set;}
        public string typeDnBCode {get;set;}
    }
    
    public class DNBStockExchanges{
        public string tickerName {get;set;}
        public DNBExchangeName exchangeName {get;set;}
        public DNBExchangeCountry isoAlpha2Code {get;set;}
        public boolean isPrimary {get;set;}       
    }
    
    public class DNBExchangeName{
        public string description {get;set;}
    }
    
    public class DNBExchangeCountry{
        public string isoAlpha2Code {get;set;}
    }
    
    public class DNBPrimaryIndustryCode{
        public string usSicV4 {get;set;}
        public string usSicV4Description {get;set;}
    }
    */
    public class DNBCorporateLinkage{
        //public boolean isBranch {get;set;}
        //public integer branchesCount {get;set;}
        //public List<DNBFamilytreeRolesPlayed> familytreeRolesPlayed {get;set;}
        //public integer globalUltimateFamilyTreeMembersCount {get;set;}
        public DNBGlobalUltimate globalUltimate {get;set;}
        public DNBDomesticUltimate domesticUltimate {get;set;}
        //public DNBParent parent {get;set;}
        //public DNBHeadQuarter headQuarter {get;set;}
        //public integer hierarchyLevel {get;set;}
        
    }
    /*
    public class DNBFamilytreeRolesPlayed{
        public string description {get;set;}
        public Integer dnbCode {get;set;}
    }
    */
    public class DNBGlobalUltimate{
        public string duns {get;set;}
        public string primaryName {get;set;}
        public DNBAddress primaryAddress {get;set;}
        public List<DNBNumberOfEmployees> numberOfEmployees {get;set;}
        public List<DNBFinancials> financials {get;set;}
    }
    /*
    public class DNBParent{
        public string duns {get;set;}
        public string primaryName {get;set;}
        public DNBAddress primaryAddress {get;set;}
    }
    */
    public class DNBFinancials{
        public List<DNBYearlyRevenue> yearlyRevenue {get;set;}
        //public string financialStatementToDate {get;set;}
        //public string financialStatementFromDate {get;set;}
        //public string financialStatementDuration {get;set;}
        //public string unitCode {get;set;}
        //public string informationScopeDescription {get;set;}
        //public integer informationScopeDnBCode {get;set;}
        //public string reliabilityDescription {get;set;}
        //public integer reliabilityDnBCode {get;set;}
        //public string accountantName {get;set;}
        //public List<DNBAccountantOpinions> accountantOpinions {get;set;}
        //public string approvalDate {get;set;}
        //public List<DNBComments> comments {get;set;}
        //public string dnbCurrency {get;set;}
        //public DNBDataProvider dataProvider {get;set;}
        //public DNBDeliveryMethod deliveryMethod {get;set;}
        //public List<DNBExplanations> explanations {get;set;}
        //public string filingDate {get;set;}
        //public DNBFinancialRatios financialRatios {get;set;}
        //public List<DNBInformationSourceIndividual> informationSourceIndividual {get;set;} 
        //public boolean isAudited {get;set;}
        //public boolean isFiscal {get;set;}
        //public boolean isQualified {get;set;}
        //public boolean isRestated {get;set;}
        //public boolean isSigned {get;set;}
        //public boolean isUnbalanced {get;set;}
        //public DNBNonSpecificSource nonSpecificSource {get;set;}
        //public DNBOverview overview {get;set;}
        //public string recievedTimestamp {get;set;}
        //public DNBReliability reliability {get;set;}
        //public DNBStatementTemplate statementTemplate {get;set;}
        //public string units {get;set;}
        //public DNBNotAuditedReason notAuditedReason {get;set;}
    }
    
    public class DNBAssessment{
        public DNBFailureScore failureScore {get;set;}
        public DNBCreditLimitRecommendation creditLimitRecommendation {get;set;}
        public DNBDelinquencyScore delinquencyScore {get;set;}
        //public DNBEmergingMarketMediationScore emergingMarketMediationScore {get;set;}
        //public DNBFinancialCondition financialCondition {get; set;}
        //public boolean hasSevereNegativeEvents {get;set;}
        //public DNBHistoryRating historyRating {get;set;}
        //public DNBNordicAAARating nordicAAARating {get;set;}
        public DNBStandardRating standardRating {get;set;}        
    }
    
    public class DNBFailureScore{
        public integer classScore {get;set;}
        public string classScoreDescription {get;set;}
        public string scoreDate {get;set;}
        //public DNBScoreModel scoreModel {get;set;}
        public decimal nationalPercentile {get;set;}
        //public List<DNBScoreOverrideReasons> scoreOverrideReasons {get;set;} 
    }
    
    public class DNBDelinquencyScore{
        public integer classScore {get;set;}
        public string classScoreDescription {get;set;}
        public DNBScoreCommentary scoreCommentary {get;set;}
        public string scoreDate {get;set;}
        public decimal nationalPercentile {get;set;}
        //public DNBScoreModel scoreModel {get;set;}
        //public List<DNBScoreOverrideReasons> scoreOverrideReasons {get;set;}
    }
    
    public class DNBScoreCommentary{
        public string description {get;set;}
        public integer dnbCode {get;set;}
    }
    /*
    public class DNBEmergingMarketMediationScore{
        public integer classScore {get;set;}
        public string scoreDate {get;set;}
        public DNBScoreModel scoreModel {get;set;}
    }
    
    public class DNBFinancialCondition{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBNordicAAARating{
        public DNBFinancialStrength financialStrength {get;set;} 
        public string rating {get;set;}
        public string scoreDate {get;set;}
        public DNBRiskSegment riskSegment {get;set;}
    }
    */
    public class DNBStandardRating {
        //public string financialStrength {get;set;}
        //public string rating {get;set;}
        //public List<DNBRatingOverrideReasons> ratingOverrideReasons {get;set;}
        //public List<DNBRatingReason> ratingReason {get;set;}
        //public string riskSegment {get;set;}
        public string scoreDate {get;set;}
    }
    /*
    public class DNBRatingOverrideReasons{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBRatingReason{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBFinancialStrength{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBRiskSegment {
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBHistoryRating{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBScoreModel{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBScoreOverrideReasons{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    */
    public class DNBCreditLimitRecommendation{
        public string assessmentDate {get;set;}
        public DNBMaximumRecommendedLimit maximumRecommendedLimit {get;set;}
    }
    
    public class DNBMaximumRecommendedLimit{
        public string dnbCurrency {get;set;}
        public decimal value {get;set;}
    } 
    /*
    public class DNBAccountantOpinions{
        public integer dnbCode {get;set;}
        public string description {get;set;}   
    }
    
    public class DNBComments{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBDeliveryMethod{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBExplanations{
        public integer dnbCode {get;set;}
        public string description {get;set;} 
        public integer typeDnBCode {get;set;}
    }
    
    public class DNBFinancialRatios{
        public List<DNBStatementItems> statementItems {get;set;}    
    }
    
    public class DNBStatementItems{
        public decimal value {get;set;}
        public string relativeIndustryRank {get;set;}
        public DNBItemKey itemKey {get;set;}
        public integer priority {get;set;}
    }
    
    public class DNBItemKey{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBInformationSourceIndividual{
        public string fullName {get;set;}
    }
    
    public class DNBNotAuditedReason{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBNonSpecificSource {
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBStatementTemplate{
        public integer dnbCode {get;set;}
        public string description {get;set;}    
    }
    
    public class DNBOverview{
        public decimal accountsReceivable {get;set;}  
        public decimal cashAndLiquidAssets {get;set;}  
        public decimal inventory {get;set;}  
        public decimal totalCurrentAssets {get;set;}  
        public decimal fixedAssets {get;set;}  
        public decimal intangibleAssets {get;set;}  
        public decimal totalLongTermAssets {get;set;}  
        public decimal totalAssets {get;set;}  
        public decimal totalCurrentLiabilities {get;set;}  
        public decimal longTermDebt {get;set;}  
        public decimal totalLongTermLiabilities {get;set;}  
        public decimal tangibleNetWorth {get;set;}  
        public decimal retainedEarnings {get;set;}  
        public decimal netWorth {get;set;}  
        public decimal salesRevenue {get;set;} 
        public decimal costOfSales {get;set;} 
        public decimal dividends {get;set;} 
        public decimal grossProfit {get;set;} 
        public decimal netIncome {get;set;} 
        public decimal profitBeforeTaxes {get;set;} 
        public decimal operatingProfit {get;set;} 
        public decimal workingCapital {get;set;} 
        public decimal netAssets {get;set;} 
        public decimal currentRatio {get;set;} 
        public decimal quickRatio {get;set;} 
        public decimal currentLiabilitiesOverNetWorth {get;set;} 
        public decimal totalLiabilitiesOverNetWorth {get;set;} 
        public decimal acidTestRatio {get;set;} 
        public decimal otherCurrentLiabilities {get;set;} 
        public decimal otherReceivables {get;set;} 
        public decimal tangibleAssets {get;set;} 
        public decimal capitalStock {get;set;} 
        public decimal totalIndebtedness {get;set;}         
    }
    */
    public class DNBYearlyRevenue{
        public Decimal value {get;set;}
        public string dnbCurrency {get;set;}
    }
    
    public class DNBRegistrationNumbers{
        public string registrationNumber{get;set;}
        //public string typeDescription {get;set;}
        //public integer typeDnBCode {get;set;}
        //public boolean isPreferredRegistrationNumber {get;set;}
    }
    
    public class DNBNumberOfEmployees{
        public integer value {get;set;}
        //public integer minimumValue {get;set;}
        //public integer maximumValue {get;set;}
        //public string employeeFiguresDate {get;set;}
        //public string informationScopeDescription {get;set;}
        //public integer informationScopeDnBCode {get;set;}
        //public string reliabilityDescription {get;set;}
        //public integer reliabilityDnBCode {get;set;}
        //public List<DNBEmployeeCategories> employeeCategories {get;set;}
        //public List<DNBTrend> trend {get;set;}
    }
    
    public class DNBIndustryCodes{
        public string code {get;set;}
        public string description {get;set;}
        public string typeDescription {get;set;}
        public integer typeDnbCode{get;set;}
        public integer priority{get;set;}
    }
    
    public class DNBIndustryCode{
        public string usSicV4 {get;set;}
        public string usSicV4Description {get;set;}
    }
    
    public class DNBBusinessEntityType{
        //public integer dnbCode {get;set;}
        public string description {get;set;}
    }
    
    public class DNBToken{
        public string access_token {get;set;}
        //public integer expiresIn {get;set;}        
    }
    /*
    public class DNBActivities{
        public string description {get;set;}
        public DNBLanguage language {get;set;}
    }
    
    public class DNBBanks{
        public string name {get;set;}
        public string branchname {get;set;}
        public DNBTelephoneNumber telephoneNumber {get;set;}
        public DNBAddress address {get;set;}
        public List<DNBRegistrationNumbers> registrationNumbers {get;set;}
    }
    
    public class DNBBusinessTrustIndex{
        public string scoreDate {get;set;}
        public decimal trustIndex {get;set;}
        public DNBTrustClass trustClass {get;set;}
        public decimal nationalPercentile {get;set;}
        public DNBDataProvider dataProvider {get;set;}
        public List<DNBScoreReasons> scoreReasons {get;set;}
        public DNBExcludedOrganiztion excludedOrganization {get;set;}
    }
    
    public class DNBTrustClass{
        public string description {get;set;}
        public Integer dnbCode {get;set;}      
    }
    
    public class DNBDataProvider{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBScoreReasons{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBExcludedOrganiztion{
        public string duns {get;set;}
        public string name {get;set;}
        public DNBAddress address {get;set;}
    }
    
    public class DNBCharterType{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBControlOwnershipType{
        public string description {get;set;}
        public Integer dnbCode {get;set;}   
    }
    
    */
    public class DNBDomesticUltimate{
        public string duns {get;set;}
        //public List<DNBNumberOfEmployees> numberOfEmployees {get;set;}
        public List<DNBFinancials> financials {get;set;}
        public DNBAddress primaryAddress {get;set;}
        public string primaryName {get;set;}
    }
    /*
    public class DNBEmployerDesignation{
        public string scoreDate {get;set;}
        public decimal indexScore {get;set;}
        public DNBDesignation designation {get;set;}
        public DNBReliability reliability {get;set;}
    }
    
    public class DNBDesignation{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBReliability{
        public string description {get;set;}
        public Integer dnbCode {get;set;}
    }
    
    public class DNBLegalForm{
        public string startDate {get;set;}
        public string description {get;set;}
        public Integer dnbCode {get;set;}
        public DNBRegistrationLocation registrationLocation {get;set;}
    }
    
    public class DNBRegistrationLocation{
        public string addressRegion {get;set;}
    }
    
    public class DNBMultilingualRegisteredNames{
        public DNBLanguage language{get;set;}
        public string name {get;set;}        
    }
    
    public class DNBMultilingualSearchNames{
        public DNBLanguage language{get;set;}
        public string name {get;set;} 
        public DNBWritingScript writingScript {get;set;}
    }
    
    public class DNBWritingScript{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBEmployeeCategories{
        public string employmentBasisDescription {get;set;}
        public integer employmentBasisDnBCode {get;set;}
    }
    
    public class DNBTrend{
        public DNBTimePeriod timePeriod {get;set;}
        public decimal growthRate {get;set;}
        public decimal value {get;set;}
        public string reliabilityDescription {get;set;}
        public integer reliabilityDnBCode {get;set;}
    }
    
    public class DNBTimePeriod{
        public string description {get;set;}
        public Integer dnbCode {get;set;}   
    }
    
    public class DNBOrganizationSizeCategory{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNDPreferredLanguage{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNDGeographicalPrecision{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBStandardAddressCodes{
        public string addressCode {get;set;}
        public DNBCodeType codeType {get;set;}
    }
    
    public class DNBCodeType{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBStatisticalArea{
        public string cbsaName {get;set;}
        public string cbsaCode {get;set;}
        public string economicAreaOfInfluenceCode {get;set;}
    }
    
    public class DNBUnspscCodes{
        public string code {get;set;}
        public string description {get;set;}
        public integer priority {get;set;}
    }
    
    public class DNBAwards{
        public boolean hasContracts {get;set;}   
        public boolean hasLoans {get;set;} 
        public boolean hasDebts {get;set;} 
        public boolean hasGrants {get;set;} 
        public boolean hasOpenContracts {get;set;} 
        public boolean hasOpenLoans {get;set;} 
        public boolean hasOpenDebts {get;set;} 
        public boolean hasOpenGrants {get;set;} 
    }
    */
    public class DNBFinancingEvents {
        //public boolean hasFinancingEvents {get;set;}   
        //public boolean hasOpenFinancingEvents {get;set;} 
        //public boolean hasSecuredFilings {get;set;} 
        //public boolean hasOpenSecuredFilings {get;set;} 
        //public boolean hasLetterOfLiability {get;set;} 
        //public boolean hasOpenLetterOfLiability {get;set;}
        //public boolean hasRemovedLetterOfLiability {get;set;} 
        //public boolean hasLetterOfAgreement {get;set;}
        public List<DNBFilings> filings {get;set;}
    }
    
    public class DNBLegalEvents{
        public DNBSuits suits {get;set;}
        //public boolean hasLegalEvents {get;set;}
        //public boolean hasOpenLegalEvents {get;set;} 
        //public boolean hasSuits {get;set;} 
        //public boolean hasOpenSuits {get;set;} 
        //public boolean hasLiens {get;set;} 
        //public boolean hasOpenLiens {get;set;} 
        //public boolean hasBankruptcy {get;set;} 
        //public boolean hasOpenBankruptcy {get;set;} 
        //public boolean hasJudgments {get;set;} 
        //public boolean hasOpenJudgments {get;set;} 
        //public boolean hasFinancialEmbarrassment {get;set;} 
        //public boolean hasOpenFinancialEmbarrassment {get;set;} 
        //public boolean hasCriminalProceedings {get;set;} 
        //public boolean hasOpenCriminalProceedings {get;set;} 
        //public boolean hasClaims {get;set;} 
        //public boolean hasOpenClaims {get;set;} 
        //public boolean hasDebarments {get;set;} 
        //public boolean hasOpenDebarments {get;set;} 
        //public boolean hasInsolvency {get;set;} 
        //public boolean hasLiquidation {get;set;} 
        //public boolean hasSuspensionOfPayments {get;set;} 
        //public boolean hasOtherLegalEvents {get;set;} 
    }
    
    public class DNBSuits{
        public List<DNBFilings>  filings {get;set;}   
    }
    
    public class DNBFilings{
        public boolean isStopD {get;set;} 
        
    }   
    /*
    public class DNBSignificantEvents{
        public boolean hasSignificantEvents {get;set;}
        public boolean hasOperationalEvents {get;set;}
        public boolean hasDisastrousEvents {get;set;}
        public boolean hasBurglaryOccured {get;set;}
        public boolean hasFireOccurred {get;set;}
        public boolean hasBusinessDiscontinued {get;set;}
        public boolean hasNameChange {get;set;}
        public boolean hasPartnerChange {get;set;}
        public boolean hasCEOChange {get;set;}
        public boolean hasControlChange {get;set;}
    }
    
    public class DNBViolations{
        public boolean hasEPAViolations {get;set;}
        public boolean hasOSHAViolations {get;set;}
        public boolean hasGCLCitations {get;set;}
    }
    
    public class DNBHeadQuarter{
        public string duns {get;set;}
        public string primaryName {get;set;}
        public DNBAddress primaryAddress {get;set;}
    }
    */
    public class DNBBusinessTrading{
        //public string summaryDate {get;set;}
        public List<DNBSummary> summary {get;set;}
    }
    
    public class DNBMostSeniorPrincipal{
        //public DNBGender gender {get;set;}
        //public List<DNBIdNumbers> idNumbers {get;set;}
        public List<DNBJobTitles> jobTitles {get;set;}
        //public List<DNBManagementResponsibilities> managementResponsibilities {get;set;}
        //public List<DNBOtherLanguageNames> otherLanguages {get;set;}
        //public string givenName {get;set;}
        //public string familyName {get;set;}
        public string fullName {get;set;}
        //public string middleName {get;set;}
        //public string namePrefix {get;set;}
        //public string nameSuffix {get;set;}
    }
    /*
    public class DNBGender{
        public string description {get;set;}
        public Integer dnbCode {get;set;}   
    }
    
    public class DNBIdNumbers{
        public string idNumber {get;set;}
        public DNBIdType idType {get;set;}        
    }
    */
    public class DNBJobTitles{
        public string title {get;set;}   
    }
    /*
    public class DNBManagementResponsibilities{
        public string description {get;set;}
        public string mrcCode {get;set;}
    }
    
    public class DNBOtherLanguageNames{
        public string givenName {get;set;}
        public string familyName {get;set;}
        public string fullName {get;set;}
    }
    
    public class DNBIdType{
        public string description {get;set;}
        public Integer dnbCode {get;set;}    
    }
    
    public class DNBLayOffScore{
        public integer classScore {get;set;}
        public string classScoreDEscription {get;set;}
        public decimal nationalRiskPercentile {get;set;}
        public decimal probability {get;set;}
        public string scoreDate {get;set;}
    }
    
    public class DNBTsrRating{
        public string rating {get;set;}
        public string ratingDate {get;set;}
        public string ratingRange {get;set;}
    }
    */
}