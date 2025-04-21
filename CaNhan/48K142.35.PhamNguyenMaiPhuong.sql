use BikeStores

/*Thống kê số lượng đơn đã bán của cửa hàng Santa Cruz Bikes,
sắp xếp giảm dần theo số lượng đơn đã bán.*/

--COT: id don hang, ten cua hang, sl sp da ban trong don hang
--BANG: sales.store, sales.order_items, sales.orders
--DIEU KIEN: cua cua hang Santa Cruz Bikes
--(sap xep theo so luong giam dan)

SELECT o.order_id, s.store_name, SUM(oi.quantity) AS 'SL da ban'
FROM sales.order_items oi	JOIN sales.orders o ON oi.order_id = o.order_id
							JOIN sales.stores s ON o.store_id = s.store_id
WHERE s.store_name = 'Santa Cruz Bikes'
GROUP BY o.order_id, s.store_name
ORDER BY 'SL da ban' DESC;





