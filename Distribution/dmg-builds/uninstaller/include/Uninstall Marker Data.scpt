FasdUAS 1.101.10   ��   ��    k             l     ��  ��    %  Uninstall Tool for Marker Data     � 	 	 >   U n i n s t a l l   T o o l   f o r   M a r k e r   D a t a   
  
 l     ��������  ��  ��        l     ��  ��    F @ Confirm with the user before proceeding with the uninstallation     �   �   C o n f i r m   w i t h   t h e   u s e r   b e f o r e   p r o c e e d i n g   w i t h   t h e   u n i n s t a l l a t i o n      l     ����  I    ��  
�� .sysodlogaskr        TEXT  m        �  . T h i s   U n i n s t a l l e r   T o o l   w i l l   c o m p l e t e l y   a n d   p e r m a n e n t l y   r e m o v e   M a r k e r   D a t a   f r o m   y o u r   s y s t e m ,   i n c l u d i n g   C a c h e s ,   P r e f e r e n c e s ,   C o n f i g u r a t i o n s   a n d   D a t a b a s e s .  ��  
�� 
btns  J           m       �    A b o r t   &   Q u i t   ��  m         � ! ! * U n i n s t a l l   M a r k e r   D a t a��    �� " #
�� 
dflt " m     $ $ � % %  A b o r t   &   Q u i t # �� &��
�� 
disp & l  	  '���� ' I  	 �� (��
�� .sysorpthalis        TEXT ( m   	 
 ) ) � * *  a p p l e t . i c n s��  ��  ��  ��  ��  ��     + , + l    -���� - r     . / . n     0 1 0 1    ��
�� 
bhit 1 1    ��
�� 
rslt / o      ���� 0 
userchoice 
userChoice��  ��   ,  2 3 2 l     ��������  ��  ��   3  4 5 4 l     �� 6 7��   6 < 6 Set the name of the application you want to uninstall    7 � 8 8 l   S e t   t h e   n a m e   o f   t h e   a p p l i c a t i o n   y o u   w a n t   t o   u n i n s t a l l 5  9 : 9 l    ;���� ; r     < = < m     > > � ? ?  M a r k e r   D a t a = o      ���� 0 appname appName��  ��   :  @ A @ l     ��������  ��  ��   A  B C B l     �� D E��   D A ; Function to get the full path to the user's home directory    E � F F v   F u n c t i o n   t o   g e t   t h e   f u l l   p a t h   t o   t h e   u s e r ' s   h o m e   d i r e c t o r y C  G H G i      I J I I      �������� &0 gethomefolderpath getHomeFolderPath��  ��   J L     	 K K n      L M L 1    ��
�� 
psxp M l     N���� N I    �� O��
�� .earsffdralis        afdr O m     ��
�� afdrcusr��  ��  ��   H  P Q P l     ��������  ��  ��   Q  R S R l     �� T U��   T 4 . Check if the application is currently running    U � V V \   C h e c k   i f   t h e   a p p l i c a t i o n   i s   c u r r e n t l y   r u n n i n g S  W X W l   ~ Y���� Y Z    ~ Z [�� \ Z =   ) ] ^ ] n    ' _ ` _ 1   # '��
�� 
prun ` 4    #�� a
�� 
capp a o   ! "���� 0 appname appName ^ m   ' (��
�� boovtrue [ k   , n b b  c d c l  , ,�� e f��   e   Quit the application    f � g g *   Q u i t   t h e   a p p l i c a t i o n d  h i h O  , ; j k j I  5 :������
�� .aevtquitnull��� ��� null��  ��   k 4   , 2�� l
�� 
capp l o   0 1���� 0 appname appName i  m n m l  < A o p q o I  < A�� r��
�� .sysodelanull��� ��� nmbr r m   < =���� ��   p C = Add a delay if needed for the application to quit gracefully    q � s s z   A d d   a   d e l a y   i f   n e e d e d   f o r   t h e   a p p l i c a t i o n   t o   q u i t   g r a c e f u l l y n  t u t l  B B��������  ��  ��   u  v w v l  B B�� x y��   x A ; Verify if the application has been successfully terminated    y � z z v   V e r i f y   i f   t h e   a p p l i c a t i o n   h a s   b e e n   s u c c e s s f u l l y   t e r m i n a t e d w  {�� { Z   B n | }�� ~ | >  B N  �  n   B L � � � 1   H L��
�� 
prun � 4   B H�� �
�� 
capp � o   F G���� 0 appname appName � m   L M��
�� boovtrue } k   Q ^ � �  � � � l  Q Q�� � ���   � &   Application has been terminated    � � � � @   A p p l i c a t i o n   h a s   b e e n   t e r m i n a t e d �  ��� � I  Q ^�� ���
�� .sysoexecTEXT���     TEXT � b   Q Z � � � b   Q V � � � m   Q T � � � � � 
 e c h o   � o   T U���� 0 appname appName � m   V Y � � � � �    t e r m i n a t e d .��  ��  ��   ~ k   a n � �  � � � l  a a�� � ���   � * $ Unable to terminate the application    � � � � H   U n a b l e   t o   t e r m i n a t e   t h e   a p p l i c a t i o n �  ��� � I  a n�� ���
�� .sysoexecTEXT���     TEXT � b   a j � � � b   a f � � � m   a d � � � � � 2 e c h o   U n a b l e   t o   t e r m i n a t e   � o   d e���� 0 appname appName � m   f i � � � � �  .��  ��  ��  ��   \ k   q ~ � �  � � � l  q q�� � ���   � + % Application is not currently running    � � � � J   A p p l i c a t i o n   i s   n o t   c u r r e n t l y   r u n n i n g �  ��� � I  q ~�� ���
�� .sysoexecTEXT���     TEXT � b   q z � � � b   q v � � � m   q t � � � � � 
 e c h o   � o   t u���� 0 appname appName � m   v y � � � � � 4   i s   n o t   c u r r e n t l y   r u n n i n g .��  ��  ��  ��   X  � � � l     ��������  ��  ��   �  � � � l     �� � ���   � , & Marker Data Files & Folders to Remove    � � � � L   M a r k e r   D a t a   F i l e s   &   F o l d e r s   t o   R e m o v e �  � � � l   � ����� � r    � � � � J    � � �  � � � l 	  � ����� � m    � � � � � � : / A p p l i c a t i o n s / M a r k e r   D a t a . a p p��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � 2 / M o v i e s / M a r k e r   D a t a   C a c h e��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � � / L i b r a r y / S a v e d   A p p l i c a t i o n   S t a t e / c o . t h e a c h a r y a . M a r k e r D a t a . s a v e d S t a t e��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � P / L i b r a r y / W e b K i t / c o . t h e a c h a r y a . M a r k e r D a t a��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ��������� &0 gethomefolderpath getHomeFolderPath��  ��   � m   � � � � � � � \ / L i b r a r y / H T T P S t o r a g e s / c o . t h e a c h a r y a . M a r k e r D a t a��  ��  ��  ��   �  � � � l 	 � � ����� � l  � � ����� � b   � � � � � I   � ���~�}� &0 gethomefolderpath getHomeFolderPath�~  �}   � m   � � � � � � � x / L i b r a r y / H T T P S t o r a g e s / c o . t h e a c h a r y a . M a r k e r D a t a . b i n a r y c o o k i e s��  ��  ��  ��   �  � � � l 	 � � ��|�{ � l  � � ��z�y � b   � � � � � I   � ��x�w�v�x &0 gethomefolderpath getHomeFolderPath�w  �v   � m   � � � � � � � | / L i b r a r y / C o n t a i n e r s / c o . t h e a c h a r y a . M a r k e r D a t a . W o r k f l o w E x t e n s i o n�z  �y  �|  �{   �  � � � l 	 � � ��u�t � l  � � ��s�r � b   � � � � � I   � ��q�p�o�q &0 gethomefolderpath getHomeFolderPath�p  �o   � m   � � � � � � � � / L i b r a r y / A p p l i c a t i o n   S c r i p t s / c o . t h e a c h a r y a . M a r k e r D a t a . W o r k f l o w E x t e n s i o n�s  �r  �u  �t   �  � � � l 	 � � �n�m  l  � ��l�k b   � � I   � ��j�i�h�j &0 gethomefolderpath getHomeFolderPath�i  �h   m   � � � P / L i b r a r y / A p p l i c a t i o n   S u p p o r t / M a r k e r   D a t a�l  �k  �n  �m   �  l 	 � ��g�f l  � �	�e�d	 b   � �

 I   � ��c�b�a�c &0 gethomefolderpath getHomeFolderPath�b  �a   m   � � � f / L i b r a r y / P r e f e r e n c e s / c o . t h e a c h a r y a . M a r k e r D a t a . p l i s t�e  �d  �g  �f   �` l 	 � ��_�^ m   � � � � / p r i v a t e / v a r / f o l d e r s / y z / j v 3 j h f b d 0 z d 4 m z f d l d h y p s 8 8 0 0 0 0 g n / C / c o . t h e a c h a r y a . M a r k e r D a t a�_  �^  �`   � o      �]�] 0 folderpaths folderPaths��  ��   �  l     �\�[�Z�\  �[  �Z    l     �Y�Y   1 + Lists to store deleted and undeleted paths    � V   L i s t s   t o   s t o r e   d e l e t e d   a n d   u n d e l e t e d   p a t h s  l  � ��X�W r   � � J   � ��V�V   o      �U�U 0 deletedpaths deletedPaths�X  �W    l  � � �T�S  r   � �!"! J   � ��R�R  " o      �Q�Q  0 undeletedpaths undeletedPaths�T  �S   #$# l     �P�O�N�P  �O  �N  $ %&% l  �;'�M�L' Z   �;()�K*( =  � �+,+ o   � ��J�J 0 
userchoice 
userChoice, m   � �-- �.. * U n i n s t a l l   M a r k e r   D a t a) k   �// 010 l  � ��I23�I  2 / ) Delete the folders with admin privileges   3 �44 R   D e l e t e   t h e   f o l d e r s   w i t h   a d m i n   p r i v i l e g e s1 565 X   �E7�H87 k  @99 :;: r  <=< b  >?> m  @@ �AA  r m   - r f  ? n  BCB 1  �G
�G 
strqC n  DED 1  �F
�F 
psxpE o  �E�E 0 
folderpath 
folderPath= o      �D�D 0 deletecommand deleteCommand; F�CF Q  @GHIG k   2JJ KLK I  +�BMN
�B .sysoexecTEXT���     TEXTM o   #�A�A 0 deletecommand deleteCommandN �@O�?
�@ 
badmO m  &'�>
�> boovtrue�?  L P�=P r  ,2QRQ o  ,-�<�< 0 
folderpath 
folderPathR n      STS  ;  01T o  -0�;�; 0 deletedpaths deletedPaths�=  H R      �:U�9
�: .ascrerr ****      � ****U o      �8�8 0 errmsg errMsg�9  I r  :@VWV o  :;�7�7 0 
folderpath 
folderPathW n      XYX  ;  >?Y o  ;>�6�6  0 undeletedpaths undeletedPaths�C  �H 0 
folderpath 
folderPath8 o   � ��5�5 0 folderpaths folderPaths6 Z[Z l FF�4�3�2�4  �3  �2  [ \]\ l FF�1^_�1  ^ R L Create a text file on the desktop with lists of deleted and undeleted paths   _ �`` �   C r e a t e   a   t e x t   f i l e   o n   t h e   d e s k t o p   w i t h   l i s t s   o f   d e l e t e d   a n d   u n d e l e t e d   p a t h s] aba r  FScdc l FOe�0�/e b  FOfgf I  FK�.�-�,�. &0 gethomefolderpath getHomeFolderPath�-  �,  g m  KNhh �ii  / D e s k t o p /�0  �/  d o      �+�+ 0 desktoppath desktopPathb jkj r  Tglml I Tc�*no
�* .rdwropenshor       filen l T[p�)�(p b  T[qrq o  TW�'�' 0 desktoppath desktopPathr m  WZss �tt : M a r k e r - D a t a _ U n i n s t a l l _ L o g . t x t�)  �(  o �&u�%
�& 
permu m  ^_�$
�$ boovtrue�%  m o      �#�# 0 logfile logFilek vwv l hsxyzx I hs�"{|
�" .rdwrseofnull���     ****{ o  hk�!�! 0 logfile logFile| � }�
�  
set2} m  no��  �  y %  Clearing the file if it exists   z �~~ >   C l e a r i n g   t h e   f i l e   i f   i t   e x i s t sw � I t����
� .rdwrwritnull���     ****� b  t{��� m  tw�� ��� 4 D e l e t e d   F i l e s   a n d   F o l d e r s :� 1  wz�
� 
lnfd� ���
� 
refn� o  ~��� 0 logfile logFile�  � ��� X  ������ I �����
� .rdwrwritnull���     ****� b  ����� o  ���� 0 itempath itemPath� 1  ���
� 
lnfd� ���
� 
refn� o  ���� 0 logfile logFile�  � 0 itempath itemPath� o  ���� 0 deletedpaths deletedPaths� ��� I �����
� .rdwrwritnull���     ****� 1  ���
� 
lnfd� ���
� 
refn� o  ���� 0 logfile logFile�  � ��� I �����
� .rdwrwritnull���     ****� b  ����� m  ���� ��� n U n d e l e t e d   F i l e s   a n d   F o l d e r s   ( M a n u a l   D e l e t i o n   R e q u i r e d ) :� 1  ���

�
 
lnfd� �	��
�	 
refn� o  ���� 0 logfile logFile�  � ��� X  ������ I �����
� .rdwrwritnull���     ****� b  ����� o  ���� 0 itempath itemPath� 1  ���
� 
lnfd� ���
� 
refn� o  ��� �  0 logfile logFile�  � 0 itempath itemPath� o  ������  0 undeletedpaths undeletedPaths� ��� I ������
�� .rdwrclosnull���     ****� o  ������ 0 logfile logFile��  � ��� l ��������  ��  ��  � ��� I ����
�� .sysodlogaskr        TEXT� m  �� ��� � M a r k e r   D a t a   w a s   s u c c e s s f u l l y   r e m o v e d   f r o m   y o u r   s y s t e m .   L o g   f i l e   c r e a t e d   o n   D e s k t o p .� ����
�� 
btns� J  �� ���� m  �� ���  O K��  � ����
�� 
dflt� m  �� ���  O K� �����
�� 
disp� l ������ I �����
�� .sysorpthalis        TEXT� m  �� ���  a p p l e t . i c n s��  ��  ��  ��  � ���� l ��������  ��  ��  ��  �K  * k  ";�� ��� l ""������  � &   User aborted the uninstallation   � ��� @   U s e r   a b o r t e d   t h e   u n i n s t a l l a t i o n� ���� I ";����
�� .sysodlogaskr        TEXT� m  "%�� ��� . U n i n s t a l l a t i o n   A b o r t e d .� ����
�� 
btns� J  &+�� ���� m  &)�� ���  O K��  � ����
�� 
dflt� m  ,/�� ���  O K� �����
�� 
disp� l 07������ I 07�����
�� .sysorpthalis        TEXT� m  03�� ���  a p p l e t . i c n s��  ��  ��  ��  ��  �M  �L  & ���� l     ��������  ��  ��  ��       �������  � ������ &0 gethomefolderpath getHomeFolderPath
�� .aevtoappnull  �   � ****� �� J���������� &0 gethomefolderpath getHomeFolderPath��  ��  �  � ������
�� afdrcusr
�� .earsffdralis        afdr
�� 
psxp�� 
�j �,E� �����������
�� .aevtoappnull  �   � ****� k    ;��  ��  +��  9��  W��  ��� �� �� %����  ��  ��  � �������� 0 
folderpath 
folderPath�� 0 errmsg errMsg�� 0 itempath itemPath� L ��   �� $�� )������������ >���������� � ��� � � � � ��� � � � � � � ���������-������@������������h��s����������������������������
�� 
btns
�� 
dflt
�� 
disp
�� .sysorpthalis        TEXT�� 
�� .sysodlogaskr        TEXT
�� 
rslt
�� 
bhit�� 0 
userchoice 
userChoice�� 0 appname appName
�� 
capp
�� 
prun
�� .aevtquitnull��� ��� null
�� .sysodelanull��� ��� nmbr
�� .sysoexecTEXT���     TEXT�� &0 gethomefolderpath getHomeFolderPath�� �� 0 folderpaths folderPaths�� 0 deletedpaths deletedPaths��  0 undeletedpaths undeletedPaths
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
psxp
�� 
strq�� 0 deletecommand deleteCommand
�� 
badm�� 0 errmsg errMsg��  �� 0 desktoppath desktopPath
�� 
perm
�� .rdwropenshor       file�� 0 logfile logFile
�� 
set2
�� .rdwrseofnull���     ****
�� 
lnfd
�� 
refn
�� .rdwrwritnull���     ****
�� .rdwrclosnull���     ****��<����lv����j � 
O��,E�O�E�O*a �/a ,e  G*a �/ *j UOkj O*a �/a ,e a �%a %j Y a �%a %j Y a �%a %j Oa *j+ a %*j+ a %*j+ a %*j+ a  %*j+ a !%*j+ a "%*j+ a #%*j+ a $%*j+ a %%a &a 'vE` (OjvE` )OjvE` *O�a + / O_ ([a ,a -l .kh  a /�a 0,a 1,%E` 2O _ 2a 3el O�_ )6FW X 4 5�_ *6F[OY��O*j+ a 6%E` 7O_ 7a 8%a 9el :E` ;O_ ;a <jl =Oa >_ ?%a @_ ;l AO )_ )[a ,a -l .kh �_ ?%a @_ ;l A[OY��O_ ?a @_ ;l AOa B_ ?%a @_ ;l AO )_ *[a ,a -l .kh �_ ?%a @_ ;l A[OY��O_ ;j COa D�a Ekv�a F�a Gj � 
OPY a H�a Ikv�a J�a Kj � 
ascr  ��ޭ