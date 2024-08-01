Rails.application.config.after_initialize do
  ProcessCompaniesJob.perform_now
  CollectMoreCompanyInfoJob.perform_now
end
