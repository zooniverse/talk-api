class DataRequestExpiryWorker
  include ExpiryWorker
  self.model = ::DataRequest
end
