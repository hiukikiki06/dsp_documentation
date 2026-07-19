# ELE-D24-NguyenTrungHieu
## A. KIẾN THỨC TÌM HIỂU ĐƯỢC
### 1. I2C protocol (Inter-Integrated Circuit)
#### 1.1 Khái niệm

- I2C (Inter-Integrated Circuit): là giao thức truyền thông nối tiếp đồng bộ sử dụng 2 dây SDA và SCL để kết nối nhiều thiết bị Master và Slave trên cùng 1 bus.

- standard mode: 100 Khz.

- fast mode: 400 khz.

#### 1.2 Bus vật lý I2C

![alt text](image.png)

- Cả hai đường dây I2C (SDA và SCL) đều được cấu hình cực máng hở open-drain. Nó có nghĩa là bất kỳ thiết bị / IC trên mạng I2C có thể lái SDA và SCl xuống mức thấp, nhưng k thể lái chúng lên mức cao. Vì vậy, cần một điện trở kéo lên (1k hoặc 4,7k) được sử dụng cho mỗi đường bus, để giữ cho chúng ở mức điện áp cao.

- Lý do sử dụng một hệ thống cực máng hở (open drain) là để không xảy ra hiện tượng ngắn mạch, điều này có thể xảy ra khi một thiết bị cố gắng kéo đường dây lên cao và một số thiết bị khác cố gắng kéo đường dây xuống thấp.

#### 1.3 Tri state buffer

| X | enable | Y |
|------|-------|------|
| X | 0 | HIGH Z |
| 0 | 1 | 0 |
| 1 | 1 | 1 |

- tri_state_buffer để cho SLAVE lái khi SDA Master thẻ nổi high Z.

#### 1.4 Khung truyền dữ liệu

![alt text](image-3.png)

##### 1.4.1 Start and Stop Condition

![alt text](image-2.png)

- START: SDA kéo xuống 0 trước khi SCL kéo xuống 0.

- STOP: SCL kéo lên 1 trước khi SDA kéo lên 1.

##### 1.4.2 DATA transfer condition

![alt text](image-4.png)

- SDA thay đổi mỗi khi SCL đang ở mức 0.

- SDA ổn định khi SCL đang ở mức 1.

##### 1.4.3 ACK ( Acknowledge) và NACK (Not Acknowledge)

- Mỗi byte truyền đi bao gồm byte dữ liệu và byte địa chỉ

- ACK = 0 cho bit sender biết rắng byte nhận được 1 cách thành công (SLAVE kiểm soát).

- NACK = 1 khi MASTER không muốn nhận dữ liệu từ SLAVe nữa (MASTER kiểm soát).

##### 1.4.4 Writing to SLAVE on the FC bus

![alt text](image-6.png)

##### 1.4.5 Reading from SLAVE on the FC bus

![alt text](image-5.png)

#### 1.5 State machine and block diagram

- MASTER: 

![alt text](image-8.png)

- SLAVE:

![alt text](image-9.png)

- Block Diagram

![alt text](image-10.png)

