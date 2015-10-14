logstash-codec-evam bir logstash plugini.

Bu plugini önce logstash'in içine kurulumunu yapmak gerekiyor. 

Kolaylık olsun diye, isterseniz şu 3 dosyayı logstash'in kurulu olduğu kök dizine kopyalayın:

	evam06.conf
	logstash-codec-evam-2.0.1.gem
	json.log

Şimdi terminali açın. Logstash'in kurulu olduğu kök dizine girin ve şu komutu çalıştırmalısınız. Ancak öncesinde .gem dosyasının (plugin kodu) bulunduğu path'i not edin ve aşağıdaki komutun içine koyun:

	bin/plugin install logstash-codec-evam-2.0.1.gem

Şimdi logstash'i çalıştıracağız. Ancak önce evam06.conf dosyasını açın ve burada benim hardcode yazdığım log dosyalarının path'lerini değiştirin. Path'leri absolute path olarak yazmanız şart, relative path'ler hata üretiyor. İki tane hard coded path var:

	path => "/Users/mertnuhoglu/projects/study/study/logstash/json.log"
	path => "/Users/mertnuhoglu/projects/study/study/logstash/output_evam06.log"

İlki input alınacak json verilerinin bulunduğu log dosyası, ikincisi evam formatındaki event loglarının yazılacağı log dosyası.

Gerçek koşullarda, bu input ve output yerine logstash'in desteklediği tüm input sourcelar ve output destinationlar yazılabilir.

Bizim durumumuzda, evam sunucusuna tcp üzerinden bağlantı yapılacağından, output'taki file yerine şöyle bir konfigürasyon konulacak:

	tcp {
			host => "localhost"
			port => 6789
			message_format => "%{message}"
	}

Birden çok sayıda output ve input tanımlanabilir. Dolayısıyla, debug etmek için, tcp output konfigürasyonu dışında stdout ve file konfigürasyonlarını da tutabilirsiniz.

Gerçek koşullarda, input yerine json verilerinin çekileceği kaynak neyse onun yazılması lazım. Fakat plugin'in doğru çalışıp çalışmadığını test etmek için, file kaynağı kullanıp test yapabilirsiniz.

Test etmek için şöyle yapabilirsiniz. Mesela, yukarıda ben "json.log" adlı dosyadan verileri çekiyorum. json.log dosyasını açarsanız, birkaç tane örnek görebilirsiniz.

Test ederken önemli bir püf noktası var: logstash çalışmaya başladığında, mevcut json.log dosyasındaki verileri çekmiyor. Ancak json.log dosyasında bir değişiklik yapıp, dosyayı kaydettiğinizde, logstash otomatik olarak tüm dosyayı okuyor ve işlemeye başlıyor.


