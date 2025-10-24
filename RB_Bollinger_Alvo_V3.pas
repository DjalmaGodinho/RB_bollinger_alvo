var
  upperBand                      : float;
  lowerBand                      : float;
  distanciaBandas                : float;
  precoEntrada,stopGain,stopLoss : float;
  candleEntrada                  : integer;
  qtdContratos                   : integer;
  entradasHoje                   : integer;
  ultimoDia                      : integer;

begin
  qtdContratos := 1;

  // Zera contador em novo dia
  if Date <> ultimoDia then
  begin
    entradasHoje := 0;
    ultimoDia := Date;
  end; // fim do if Date <> ultimoDia

  // Opera apenas até 16:50
  if Time < 1650 then
  begin
    // Cálculo das bandas
    upperBand := BollingerBands(2.0,20,0)|0|;
    lowerBand := BollingerBands(2.0,20,0)|1|;
    distanciaBandas := upperBand - lowerBand;

    // Cancela ordem pendente se passou 2 candles sem execução
    if (candleEntrada > 0) and (not HasPosition) and (CurrentBar - candleEntrada >= 2) then
    begin
      CancelPendingOrders();
      candleEntrada := 0;
    end; // fim do if candleEntrada > 0

    // Regras de entrada
    if (distanciaBandas <= 250) then
    begin
      // Se não tem posição e ainda pode entrar no dia
      if (not HasPosition) and (entradasHoje < 2) then
      begin
        // 🚀 ROMPIMENTO SUPERIOR → base no candle ANTERIOR
        if (Close[1] > upperBand[1]) then
        begin
          precoEntrada := High[1] + 5;                 // 10 pts acima da máxima do candle que rompeu
          BuyLimit(precoEntrada, qtdContratos);
          candleEntrada := CurrentBar;                  // registra candle de entrada
          entradasHoje := entradasHoje + 1;
        end // fim do if Close[1] > upperBand[1]

        // 🔻 ROMPIMENTO INFERIOR → base no candle ANTERIOR
        else if (Close[1] < lowerBand[1]) then
        begin
          precoEntrada := Low[1] - 5;                  // 10 pts abaixo da mínima do candle que rompeu
          SellShortLimit(precoEntrada, qtdContratos);
          candleEntrada := CurrentBar;
          entradasHoje := entradasHoje + 1;
        end; // fim do if Close[1] < lowerBand[1]
      end // fim do if not HasPosition and entradasHoje < 3

      // Gerencia posição aberta (stop gain / stop loss)
      else if HasPosition then
      begin
        if IsBought then
        begin
          stopGain := BuyPrice + 150;
          stopLoss := BuyPrice - 150;
          SellToCoverLimit(stopGain, qtdContratos);
          SellToCoverStop(stopLoss, qtdContratos);
        end // fim do if IsBought
        else if IsSold then
        begin
          stopGain := SellPrice - 150;
          stopLoss := SellPrice + 150;
          BuyToCoverLimit(stopGain, qtdContratos);
          BuyToCoverStop(stopLoss, qtdContratos);
        end; // fim do if IsSold
      end; // fim do if HasPosition
    end; // fim do if distanciaBandas <= 250

  end // fim do if Time < 1650

  // Após 16:50 → cancela ordens
  else
  begin
    CancelPendingOrders();
  end; // fim do else Time < 1650
end;
