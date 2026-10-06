machine:
  nodeLabels:
    postfinance.ch/region: {{ default "noregion" (index .Node.Data "region") }}
