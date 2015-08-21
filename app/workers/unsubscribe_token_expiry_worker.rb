class UnsubscribeTokenExpiryWorker
  include ExpiryWorker
  self.model = ::UnsubscribeToken
end
