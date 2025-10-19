var
  upperBand                      : float;
  lowerBand                      : float;
  distanciaBandas                : float;
  precoEntrada,stopGain,stopLoss : float;
  candleEntrada                  : integer;
  qtdContratos                   : integer;
begin
  qtdContratos := 1;
  upperBand := BollingerBands(2.0,20,0)|0|;
  lowerBand := BollingerBands(2.0,20,0)|1|;
  distanciaBandas := upperBand - lowerBand;
  // cancela se passaram 2 candles e ordem não executou
  if (candleEntrada > 0) and ( not HasPosition) and (CurrentBar - candleEntrada >= 2) then
    begin
      CancelPendingOrders();
      candleEntrada := 0;
    end;
  // só abre nova se não tem posição
  if (distanciaBandas <= 250) and ( not HasPosition) then
    begin
      // rompimento de banda superior
      if (Close[1] > upperBand) then
        begin
          precoEntrada := High[1] + 5;
          // 5 pontos acima do candle que rompeu
          BuyLimit(precoEntrada,qtdContratos);
          candleEntrada := CurrentBar;
        end
      // rompimento de banda inferior
      else if (Close[1] < lowerBand) then
        begin
          precoEntrada := Low[1] - 5;
          // 5 pontos abaixo
          SellShortLimit(precoEntrada,qtdContratos);
          candleEntrada := CurrentBar;
        end;
    end;
  // se posição for aberta → protege
  if HasPosition then
    begin
      if IsBought then
        begin
          // stop e gain de 150 pontos = ~R$30,00 com 1 contrato
          stopGain := BuyPrice + 150;
          stopLoss := BuyPrice - 150;
          SellToCoverLimit(stopGain,qtdContratos);
          SellToCoverStop(stopLoss,qtdContratos);
        end
      else if IsSold then
        begin
          stopGain := SellPrice - 150;
          stopLoss := SellPrice + 150;
          BuyToCoverLimit(stopGain,qtdContratos);
          BuyToCoverStop(stopLoss,qtdContratos);
        end;
    end;
end;