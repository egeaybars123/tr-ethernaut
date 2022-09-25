// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Delegate {

  address public a;  
  address public b;

  constructor(address _owner) public {
    a = _owner;
  }

  //Metot id: 0x84c51335
  function pwn_a() public {
    a = msg.sender;
  }

  //Metot id: 0x172b87d7
  function pwn_b() public {
    b = msg.sender;
  }
}

contract Delegation {

  address public c;  
  address public owner;
  Delegate delegate;

  constructor(address _delegateAddress) public {
    delegate = Delegate(_delegateAddress);
    owner = msg.sender;
  }

  fallback() external {
    (bool result,) = address(delegate).delegatecall(msg.data);
    if (result) {
      this;
    }
  }
}

/*
SOLIDITY AKILLI SÖZLEŞMELERİNDEKİ STORAGE ANLATIMI:

Yukarıda görmüş olduğunuz iki sözleşme Ethernaut'un Delegation ve Delegate sözleşmelerine
benziyor fakat iki farkı birden fazla değişken içermeleri ve değişkenleri değiştiren metot 
bulundurmaları. Delegation sözleşmesinde Delegate sözleşmesinden çağırabileceğimiz iki metot
bulunuyor: pwn_a() ve pwn_b(). Bu iki metottan birini çağırdığımızda Delegation sözleşmesindeki
c ve owner değişkenleri nasıl etkilenecek? Gelin öğrenelim!

Bir Solidity akıllı sözleşmesinde veri yapılarını depolamak için slotlar bulunur. Toplam 2^256 adet
slot bulunur; 0'dan başlanır 2^256 -1'e kadar devam eder. Her bir slot 32 byte'lık veri depolayabilir.
Mesela, adresler 20 byte'lık, uint256 ise 32 byte'lık veri depolar. Sözleşmede en üste yazılan değişken
0. slottan başlar ve değişkeni bölmeyecek şekilde veri32 byte'lık slotu dolduracak şekilde diğer slotlara 
yazılır. Örneğin; Delegate sözleşmesinde 0. slotta a adresi var, 20 bytelık yer kaplıyor. Fakat b adresi
0. slota yazılmaz, 1. slottan başlanır çünkü ikisi de 40 bytelık alan kaplıyor. a değişkeninden sonra 8 
byte'lık bir değişken tanımlasaydık, bu değişken 0. slota yazılırdı ve b değişkeni yine 1. slottan devam 
ederdi. Burayı anladıysak, delegatecall metodunun storage slotlarıyla nasıl bir ilişkisi olduğunu öğrenelim.

Delegation sözleşmesinin fallback metodunu pwn_a() metodunun metot id'si calldata olacak şekilde çağırdık 
diyelim. Delegate sözleşmesinde pwn_a() metotu 0. slotta depolanan a değişkenini güncelleyebilecek bir ifade. 
Delegate sözleşmesine yapılan delegatecall sonucu hangi slottaki değişken güncelleyecek bir ifade varsa, Delegation 
sözleşmesinde de aynı slottaki değişken güncellenir. Yani, pwn_a() metotunu çağırmamızın sonucunda Delegation 
sözleşmesindeki c değişkeni güncelleniyor. Eğer pwn_b() metotunu çağırırsak 1. slottaki b değişkenini güncelleyecek
bir ifade bulunuyor ve bunun sonucunda Delegation sözleşmesinde de 1. slota tekabul eden owner değişkeni güncelleniyor.
Fakat şunu ifade etmeliyim ki değişken güncellemesei Delegation sözleşmesinde gerçekleşiyor, Delegate sözleşmesinde değil.

Yukarıda paylaştığım kodu Remix IDE'de deneyebilirsiniz. Kolay gelsin!
*/